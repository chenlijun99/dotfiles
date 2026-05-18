from __future__ import annotations

import argparse
import json
import logging
import os
import pwd
import shlex
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

import yaml

CONFIG_FILE_NAME = ".container-shell.yaml"
PROJECT_MARKERS = (".envrc", "devenv.nix", "devenv.yaml", "devenv.lock")
SUPPORTED_MOUNT_MODES = frozenset(("ro", "rw", "overlay"))
CERT_BUNDLE_ENV_CANDIDATES = ("NIX_SSL_CERT_FILE", "SSL_CERT_FILE")
CERT_BUNDLE_PATH_CANDIDATES = (
    "/etc/ssl/certs/ca-certificates.crt",
    "/etc/ssl/cert.pem",
    "/etc/pki/tls/certs/ca-bundle.crt",
)
RESERVED_ENV_NAMES = frozenset(
    (
        "CONTAINER_SHELL",
        "HOME",
        "LOGNAME",
        "PATH",
        "USER",
        "XDG_CONFIG_HOME",
        "XDG_DATA_HOME",
        "XDG_RUNTIME_DIR",
    )
)
SYSTEM_CONTAINER_PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
CONTAINER_INIT_PATH = Path("/tmp/container-shell-init.sh")
CONTAINER_RCFILE_PATH = Path("/tmp/container-shell.bashrc")
CONTAINER_COMMAND_PATH = Path("/tmp/container-shell-command.sh")
LOGGER = logging.getLogger("container-shell")


class ContainerShellError(RuntimeError):
    """Raised when container-shell configuration is invalid."""


@dataclass(frozen=True)
class MountSpec:
    source: Path
    target: Path
    options: str

    def podman_arg(self) -> str:
        return f"{self.source}:{self.target}:{self.options}"


@dataclass(frozen=True)
class ShellLayout:
    workdir: Path
    project_root: Path
    mount_root: Path
    write_root: Path
    active_devenv: Path | None


@dataclass(frozen=True)
class ContainerIdentity:
    user_name: str
    uid: int
    gid: int
    home_dir: Path
    runtime_dir: Path
    xdg_config_home: Path
    xdg_data_home: Path


@dataclass(frozen=True)
class ExtraMount:
    source: Path
    target: Path
    mode: str


@dataclass(frozen=True)
class OverlayScratch:
    target: Path
    upperdir: Path
    workdir: Path


@dataclass(frozen=True)
class HostScratch:
    temp_root: Path
    home_dir: Path
    runtime_dir: Path
    init_script: Path
    rcfile: Path
    command_entrypoint: Path
    devenv_upperdir: Path | None
    devenv_workdir: Path | None
    extra_overlays: tuple[OverlayScratch, ...]


def configure_logging(debug_enabled: bool) -> None:
    level = logging.DEBUG if debug_enabled else logging.INFO
    logging.basicConfig(level=level, format="container-shell: %(levelname)s: %(message)s")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="container-shell",
        description="Start an interactive Podman shell or command with host-built devenv state.",
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug logging for container preparation.",
    )
    parser.add_argument(
        "-i",
        "--image",
        default=os.environ.get("CONTAINER_SHELL_IMAGE", "ubuntu:latest"),
        help="Container image to run.",
    )
    mount_group = parser.add_mutually_exclusive_group()
    mount_group.add_argument(
        "--mount-mode",
        choices=("cwd", "project-root", "git-root"),
        default="project-root",
        help="How to choose the broad bind mount root.",
    )
    mount_group.add_argument(
        "--mount-root",
        type=Path,
        help="Explicit broad bind mount root. Must be an ancestor of the launch directory.",
    )
    parser.add_argument(
        "--write-scope",
        choices=("cwd", "project-root"),
        default="cwd",
        help="Choose whether only the launch subtree or the full project root is writable.",
    )
    parser.add_argument(
        "--extra-mount",
        action="append",
        default=[],
        metavar="PATH:MODE",
        help="Bind-mount PATH at the same location in the container using mode ro, rw, or overlay.",
    )
    parser.add_argument(
        "--extra-remap",
        action="append",
        default=[],
        metavar="SOURCE:TARGET:MODE",
        help="Bind-mount SOURCE at TARGET using mode ro, rw, or overlay.",
    )
    parser.add_argument(
        "--pass-env",
        action="append",
        default=[],
        metavar="NAME",
        help="Copy the named host environment variable into the container.",
    )
    parser.add_argument(
        "--env",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Set an additional container environment variable.",
    )
    parser.add_argument(
        "command",
        nargs=argparse.REMAINDER,
        help="Optional command to execute inside the prepared container.",
    )
    return parser.parse_args(argv)


def normalize_command(command: list[str]) -> list[str]:
    if command and command[0] == "--":
        return command[1:]
    return command


def required_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise ContainerShellError(f"missing required environment variable {name}")
    LOGGER.debug("Using host environment variable %s=%r", name, value)
    return value


def validate_env_name(name: str, *, label: str) -> str:
    if not name:
        raise ContainerShellError(f"{label} must not be empty")
    if "=" in name:
        raise ContainerShellError(f"{label} must not contain '='")
    if name in RESERVED_ENV_NAMES:
        raise ContainerShellError(f"{label} must not override reserved variable {name}")
    return name


def parse_literal_env(raw_spec: str) -> tuple[str, str]:
    name, separator, value = raw_spec.partition("=")
    if not separator:
        raise ContainerShellError(f"--env expects NAME=VALUE, got {raw_spec!r}")
    return validate_env_name(name.strip(), label=f"--env {raw_spec!r}"), value


def collect_extra_env(args: argparse.Namespace) -> dict[str, str]:
    env: dict[str, str] = {}

    for raw_name in args.pass_env:
        name = validate_env_name(raw_name.strip(), label=f"--pass-env {raw_name!r}")
        value = os.environ.get(name)
        if value is None:
            raise ContainerShellError(f"--pass-env requested missing host environment variable {name}")
        env[name] = value

    for raw_spec in args.env:
        name, value = parse_literal_env(raw_spec)
        env[name] = value

    LOGGER.debug("Collected extra container environment: %s", env)
    return env


def resolve_existing_path(path: Path, label: str) -> Path:
    try:
        return path.expanduser().resolve(strict=True)
    except FileNotFoundError as exc:
        raise ContainerShellError(f"{label} does not exist: {path}") from exc


def normalize_path_value(raw_path: object, label: str) -> Path:
    if not isinstance(raw_path, str) or not raw_path.strip():
        raise ContainerShellError(f"{label} must be a non-empty string")

    path = Path(os.path.expanduser(raw_path.strip()))
    if not path.is_absolute():
        raise ContainerShellError(f"{label} must resolve to an absolute path: {raw_path!r}")

    return Path(os.path.normpath(str(path)))


def parse_mount_mode(raw_mode: object, label: str) -> str:
    if not isinstance(raw_mode, str):
        raise ContainerShellError(f"{label} must be a string")

    mode = raw_mode.strip()
    if mode not in SUPPORTED_MOUNT_MODES:
        raise ContainerShellError(
            f"{label} must be one of {', '.join(sorted(SUPPORTED_MOUNT_MODES))}: {raw_mode!r}"
        )

    return mode


def parse_config_mount_entry(entry: object, *, config_path: Path, index: int) -> ExtraMount:
    if not isinstance(entry, dict):
        raise ContainerShellError(f"{config_path}: mounts[{index}] must be a mapping")

    mode = parse_mount_mode(entry.get("mode"), f"{config_path}: mounts[{index}].mode")

    has_path = "path" in entry
    has_source = "source" in entry
    has_target = "target" in entry

    if has_path:
        if has_source or has_target:
            raise ContainerShellError(
                f"{config_path}: mounts[{index}] cannot mix path with source/target"
            )
        path = normalize_path_value(entry.get("path"), f"{config_path}: mounts[{index}].path")
        return ExtraMount(source=path, target=path, mode=mode)

    if not has_source or not has_target:
        raise ContainerShellError(
            f"{config_path}: mounts[{index}] must set either path or both source and target"
        )

    return ExtraMount(
        source=normalize_path_value(entry.get("source"), f"{config_path}: mounts[{index}].source"),
        target=normalize_path_value(entry.get("target"), f"{config_path}: mounts[{index}].target"),
        mode=mode,
    )


def load_configured_mounts(project_root: Path) -> list[ExtraMount]:
    config_path = project_root / CONFIG_FILE_NAME
    if not config_path.exists():
        return []

    try:
        data = yaml.safe_load(config_path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ContainerShellError(f"failed to read {config_path}: {exc}") from exc
    except yaml.YAMLError as exc:
        raise ContainerShellError(f"failed to parse {config_path}: {exc}") from exc

    if data is None:
        raise ContainerShellError(f"{config_path} must not be empty")
    if not isinstance(data, dict):
        raise ContainerShellError(f"{config_path} must contain a top-level mapping")
    if data.get("version") != 1:
        raise ContainerShellError(f"{config_path} must declare version: 1")

    mounts = data.get("mounts")
    if not isinstance(mounts, list):
        raise ContainerShellError(f"{config_path} must contain a mounts list")

    return [
        parse_config_mount_entry(entry, config_path=config_path, index=index)
        for index, entry in enumerate(mounts)
    ]


def parse_extra_mount_arg(raw_spec: str) -> ExtraMount:
    path_text, separator, mode_text = raw_spec.rpartition(":")
    if not separator:
        raise ContainerShellError(f"--extra-mount expects PATH:MODE, got {raw_spec!r}")

    path = normalize_path_value(path_text, f"--extra-mount {raw_spec!r}")
    mode = parse_mount_mode(mode_text, f"--extra-mount {raw_spec!r}")
    return ExtraMount(source=path, target=path, mode=mode)


def parse_extra_remap_arg(raw_spec: str) -> ExtraMount:
    source_target, separator, mode_text = raw_spec.rpartition(":")
    if not separator:
        raise ContainerShellError(f"--extra-remap expects SOURCE:TARGET:MODE, got {raw_spec!r}")

    source_text, separator, target_text = source_target.partition(":")
    if not separator:
        raise ContainerShellError(f"--extra-remap expects SOURCE:TARGET:MODE, got {raw_spec!r}")

    return ExtraMount(
        source=normalize_path_value(source_text, f"--extra-remap {raw_spec!r} source"),
        target=normalize_path_value(target_text, f"--extra-remap {raw_spec!r} target"),
        mode=parse_mount_mode(mode_text, f"--extra-remap {raw_spec!r}"),
    )


def collect_extra_mounts(args: argparse.Namespace, project_root: Path) -> list[ExtraMount]:
    mounts = load_configured_mounts(project_root)
    mounts.extend(parse_extra_mount_arg(spec) for spec in args.extra_mount)
    mounts.extend(parse_extra_remap_arg(spec) for spec in args.extra_remap)
    return mounts


def detect_host_cert_bundle(existing_targets: set[Path]) -> tuple[ExtraMount | None, dict[str, str]]:
    candidates: list[tuple[Path, Path]] = []

    for env_name in CERT_BUNDLE_ENV_CANDIDATES:
        raw_value = os.environ.get(env_name)
        if not raw_value:
            continue

        target = Path(os.path.normpath(raw_value))
        if not target.is_absolute():
            LOGGER.debug("Ignoring %s because it is not an absolute path: %r", env_name, raw_value)
            continue
        if target in existing_targets:
            LOGGER.debug("Skipping host cert bundle from %s because %s is already mounted", env_name, target)
            continue
        try:
            source = target.resolve(strict=True)
        except FileNotFoundError:
            LOGGER.debug("Ignoring %s because the bundle path does not exist: %s", env_name, target)
            continue
        if not source.is_file():
            LOGGER.debug("Ignoring %s because the bundle path is not a file: %s", env_name, source)
            continue
        candidates.append((source, target))

    for raw_path in CERT_BUNDLE_PATH_CANDIDATES:
        target = Path(raw_path)
        if target in existing_targets:
            continue
        try:
            source = target.resolve(strict=True)
        except FileNotFoundError:
            continue
        if not source.is_file():
            continue
        candidates.append((source, target))

    for source, target in candidates:
        env = {
            "NIX_SSL_CERT_FILE": str(target),
            "SSL_CERT_FILE": str(target),
            "CURL_CA_BUNDLE": str(target),
            "GIT_SSL_CAINFO": str(target),
            "REQUESTS_CA_BUNDLE": str(target),
        }
        LOGGER.debug("Using host certificate bundle %s mounted at %s", source, target)
        return ExtraMount(source=source, target=target, mode="ro"), env

    LOGGER.debug("No host certificate bundle detected for container-shell")
    return None, {}


def ensure_mount_sources(mounts: list[ExtraMount]) -> None:
    for mount in mounts:
        if mount.mode == "overlay":
            if mount.source.exists() and not mount.source.is_dir():
                raise ContainerShellError(
                    f"overlay mount source must be a directory: {mount.source}"
                )
            try:
                mount.source.mkdir(parents=True, exist_ok=True)
            except OSError as exc:
                raise ContainerShellError(
                    f"failed to prepare overlay mount directory {mount.source}: {exc}"
                ) from exc
            continue

        if mount.mode == "ro":
            if not mount.source.exists():
                raise ContainerShellError(f"read-only mount source does not exist: {mount.source}")
            continue

        if mount.source.exists():
            continue

        try:
            mount.source.mkdir(parents=True, exist_ok=True)
        except OSError as exc:
            raise ContainerShellError(
                f"failed to prepare writable mount source {mount.source}: {exc}"
            ) from exc


def built_in_mount_targets(layout: ShellLayout, identity: ContainerIdentity) -> set[Path]:
    targets = {
        layout.mount_root,
        layout.write_root,
        identity.home_dir,
        identity.runtime_dir,
        Path("/nix/store"),
        CONTAINER_INIT_PATH,
        CONTAINER_RCFILE_PATH,
        CONTAINER_COMMAND_PATH,
    }
    if layout.active_devenv is not None:
        targets.add(layout.active_devenv)
    return targets


def validate_extra_mount_targets(
    layout: ShellLayout,
    identity: ContainerIdentity,
    mounts: list[ExtraMount],
) -> None:
    seen_targets = built_in_mount_targets(layout, identity)
    for mount in mounts:
        if mount.target in seen_targets:
            raise ContainerShellError(f"duplicate container mount target: {mount.target}")
        seen_targets.add(mount.target)


def find_nearest_ancestor_with_markers(start: Path, markers: tuple[str, ...]) -> Path | None:
    for candidate in (start, *start.parents):
        if any((candidate / marker).exists() for marker in markers):
            return candidate
    return None


def is_within(path: Path, ancestor: Path) -> bool:
    try:
        path.relative_to(ancestor)
        return True
    except ValueError:
        return False


def ensure_supported_launch_directory(workdir: Path) -> None:
    home_dir = Path.home().resolve()
    if workdir == home_dir:
        raise ContainerShellError(
            "launching container-shell from $HOME is not supported because it conflicts "
            "with the synthetic container home mount"
        )


def detect_project_root(workdir: Path) -> Path:
    project_root = find_nearest_ancestor_with_markers(workdir, PROJECT_MARKERS) or workdir
    LOGGER.debug("Detected project root: %s", project_root)
    return project_root


def detect_git_root(workdir: Path) -> Path | None:
    git_root = find_nearest_ancestor_with_markers(workdir, (".git",))
    LOGGER.debug("Detected git root: %s", git_root)
    return git_root


def is_dangerously_broad_root(path: Path) -> bool:
    root = Path(path.anchor)
    home = Path.home().resolve()
    broad_candidates = {root}

    if home.parent != home:
        broad_candidates.add(home.parent)

    return path in broad_candidates


def determine_mount_root(args: argparse.Namespace, workdir: Path, project_root: Path) -> Path:
    if args.mount_root is not None:
        mount_root = resolve_existing_path(args.mount_root, "mount root")
        LOGGER.debug("Using explicit mount root: %s", mount_root)
    elif args.mount_mode == "cwd":
        mount_root = workdir
        LOGGER.debug("Using cwd as mount root: %s", mount_root)
    elif args.mount_mode == "git-root":
        mount_root = detect_git_root(workdir) or project_root
        LOGGER.debug("Using git-root mount mode, selected mount root: %s", mount_root)
    else:
        mount_root = project_root
        LOGGER.debug("Using project-root mount mode, selected mount root: %s", mount_root)

    if not is_within(workdir, mount_root):
        raise ContainerShellError(
            f"mount root {mount_root} must be an ancestor of launch directory {workdir}"
        )

    if project_root != workdir and not is_within(project_root, mount_root):
        raise ContainerShellError(
            f"mount root {mount_root} is too narrow to include the active project root {project_root}"
        )

    if is_dangerously_broad_root(mount_root):
        raise ContainerShellError(f"refusing to mount dangerously broad root {mount_root}")

    return mount_root


def determine_write_root(args: argparse.Namespace, workdir: Path, project_root: Path) -> Path:
    if args.write_scope == "project-root":
        LOGGER.debug("Using project root as write root: %s", project_root)
        return project_root
    LOGGER.debug("Using cwd as write root: %s", workdir)
    return workdir


def build_layout(args: argparse.Namespace) -> ShellLayout:
    workdir = Path.cwd().resolve()
    LOGGER.debug("Resolved launch directory to %s", workdir)
    ensure_supported_launch_directory(workdir)
    project_root = detect_project_root(workdir)
    mount_root = determine_mount_root(args, workdir, project_root)
    write_root = determine_write_root(args, workdir, project_root)

    if not is_within(write_root, mount_root):
        raise ContainerShellError(
            f"write root {write_root} must stay inside mount root {mount_root}"
        )

    active_devenv = project_root / ".devenv"
    if active_devenv.exists():
        active_devenv = active_devenv.resolve(strict=True)
        if is_within(workdir, active_devenv):
            raise ContainerShellError("launching container-shell from inside .devenv is not supported")
    else:
        active_devenv = None

    layout = ShellLayout(
        workdir=workdir,
        project_root=project_root,
        mount_root=mount_root,
        write_root=write_root,
        active_devenv=active_devenv,
    )
    LOGGER.debug("Resolved shell layout: %s", layout)
    return layout


def username_for_uid(uid: int) -> str:
    user_name = pwd.getpwuid(uid).pw_name
    LOGGER.debug("Resolved uid %s to username %s", uid, user_name)
    return user_name


def build_identity(uid: int, gid: int) -> ContainerIdentity:
    user_name = username_for_uid(uid)
    home_dir = Path("/home") / user_name
    runtime_dir = Path("/run/user") / str(uid)
    identity = ContainerIdentity(
        user_name=user_name,
        uid=uid,
        gid=gid,
        home_dir=home_dir,
        runtime_dir=runtime_dir,
        xdg_config_home=home_dir / ".config",
        xdg_data_home=home_dir / ".local/share",
    )
    LOGGER.debug("Resolved container identity: %s", identity)
    return identity


def create_host_scratch(
    temp_root: Path,
    identity: ContainerIdentity,
    layout: ShellLayout,
    extra_mounts: list[ExtraMount],
) -> HostScratch:
    home_dir = temp_root / "home" / identity.user_name
    runtime_dir = temp_root / "run" / str(identity.uid)
    init_script = temp_root / "container-shell-init.sh"
    rcfile = temp_root / "container-shell.bashrc"
    command_entrypoint = temp_root / "container-shell-command.sh"

    home_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)

    devenv_upperdir: Path | None = None
    devenv_workdir: Path | None = None
    if layout.active_devenv is not None:
        devenv_root = temp_root / "devenv-overlay"
        devenv_upperdir = devenv_root / "upper"
        devenv_workdir = devenv_root / "work"
        devenv_upperdir.mkdir(parents=True, exist_ok=True)
        devenv_workdir.mkdir(parents=True, exist_ok=True)

    extra_overlays: list[OverlayScratch] = []
    for index, mount in enumerate(extra_mounts):
        if mount.mode != "overlay":
            continue
        overlay_root = temp_root / "mount-overlays" / str(index)
        upperdir = overlay_root / "upper"
        workdir = overlay_root / "work"
        upperdir.mkdir(parents=True, exist_ok=True)
        workdir.mkdir(parents=True, exist_ok=True)
        extra_overlays.append(OverlayScratch(target=mount.target, upperdir=upperdir, workdir=workdir))

    # Some bind mounts target paths nested under the scratch home/runtime mounts. If those
    # nested targets do not already exist in the scratch source tree, Podman will create
    # placeholder files or directories for them while preparing the mounts. In our rootless
    # --userns=keep-id setup those placeholders can end up owned by the subordinate host
    # uid:gid mapped for container root (for example 231072:231072) instead of the invoking
    # user, which then breaks later writes into scratch and scratch cleanup. Pre-create the
    # nested targets here so they stay owned by the invoking user.
    prepare_nested_scratch_mount_targets(
        home_dir=home_dir,
        runtime_dir=runtime_dir,
        identity=identity,
        layout=layout,
        extra_mounts=extra_mounts,
    )

    scratch = HostScratch(
        temp_root=temp_root,
        home_dir=home_dir,
        runtime_dir=runtime_dir,
        init_script=init_script,
        rcfile=rcfile,
        command_entrypoint=command_entrypoint,
        devenv_upperdir=devenv_upperdir,
        devenv_workdir=devenv_workdir,
        extra_overlays=tuple(extra_overlays),
    )
    LOGGER.debug("Prepared host scratch paths: %s", scratch)
    return scratch


def mount_target_is_directory(mount: ExtraMount) -> bool:
    if mount.mode == "overlay":
        return True
    return mount.source.is_dir()


def nested_scratch_mount_targets(
    layout: ShellLayout,
    extra_mounts: list[ExtraMount],
) -> list[tuple[Path, bool]]:
    targets: list[tuple[Path, bool]] = [
        (layout.mount_root, True),
        (layout.write_root, True),
    ]
    if layout.active_devenv is not None:
        targets.append((layout.active_devenv, True))
    targets.extend((mount.target, mount_target_is_directory(mount)) for mount in extra_mounts)
    return targets


def materialize_nested_mount_target(
    *,
    scratch_source: Path,
    scratch_target: Path,
    mount_target: Path,
    is_directory: bool,
) -> None:
    if mount_target == scratch_target or not is_within(mount_target, scratch_target):
        return

    placeholder = scratch_source / mount_target.relative_to(scratch_target)
    try:
        if is_directory:
            if placeholder.exists() and not placeholder.is_dir():
                raise ContainerShellError(
                    f"expected directory mount placeholder, found file: {placeholder}"
                )
            placeholder.mkdir(parents=True, exist_ok=True)
            return

        placeholder.parent.mkdir(parents=True, exist_ok=True)
        if placeholder.exists():
            if placeholder.is_dir():
                raise ContainerShellError(
                    f"expected file mount placeholder, found directory: {placeholder}"
                )
            return
        placeholder.touch()
    except OSError as exc:
        raise ContainerShellError(f"failed to prepare nested mount target {placeholder}: {exc}") from exc


def prepare_nested_scratch_mount_targets(
    *,
    home_dir: Path,
    runtime_dir: Path,
    identity: ContainerIdentity,
    layout: ShellLayout,
    extra_mounts: list[ExtraMount],
) -> None:
    nested_targets = nested_scratch_mount_targets(layout, extra_mounts)
    for mount_target, is_directory in nested_targets:
        materialize_nested_mount_target(
            scratch_source=home_dir,
            scratch_target=identity.home_dir,
            mount_target=mount_target,
            is_directory=is_directory,
        )
        materialize_nested_mount_target(
            scratch_source=runtime_dir,
            scratch_target=identity.runtime_dir,
            mount_target=mount_target,
            is_directory=is_directory,
        )


def build_mounts(
    layout: ShellLayout,
    scratch: HostScratch,
    identity: ContainerIdentity,
    extra_mounts: list[ExtraMount],
) -> list[MountSpec]:
    mounts: list[MountSpec] = []

    if layout.mount_root == layout.write_root:
        mounts.append(MountSpec(layout.mount_root, layout.mount_root, "rw"))
    else:
        mounts.append(MountSpec(layout.mount_root, layout.mount_root, "ro"))
        mounts.append(MountSpec(layout.write_root, layout.write_root, "rw"))

    if layout.active_devenv is not None:
        if scratch.devenv_upperdir is None or scratch.devenv_workdir is None:
            raise ContainerShellError("missing overlay scratch directories for active .devenv")
        mounts.append(
            MountSpec(
                layout.active_devenv,
                layout.active_devenv,
                f"O,upperdir={scratch.devenv_upperdir},workdir={scratch.devenv_workdir}",
            )
        )

    mounts.extend(
        [
            MountSpec(scratch.home_dir, identity.home_dir, "rw"),
            MountSpec(scratch.runtime_dir, identity.runtime_dir, "rw"),
            MountSpec(Path("/nix/store"), Path("/nix/store"), "ro"),
            MountSpec(scratch.init_script, CONTAINER_INIT_PATH, "ro"),
            MountSpec(scratch.rcfile, CONTAINER_RCFILE_PATH, "ro"),
            MountSpec(scratch.command_entrypoint, CONTAINER_COMMAND_PATH, "ro"),
        ]
    )

    overlay_by_target = {overlay.target: overlay for overlay in scratch.extra_overlays}
    for mount in extra_mounts:
        options = mount.mode
        if mount.mode == "overlay":
            overlay = overlay_by_target.get(mount.target)
            if overlay is None:
                raise ContainerShellError(
                    f"missing overlay scratch directories for mount target {mount.target}"
                )
            options = f"O,upperdir={overlay.upperdir},workdir={overlay.workdir}"
        mounts.append(MountSpec(mount.source, mount.target, options))

    LOGGER.debug("Prepared mount list: %s", mounts)
    return mounts


def shell_quote(value: Path | str) -> str:
    return shlex.quote(str(value))


def build_init_script(layout: ShellLayout) -> str:
    direnv_toml_lines = [
        "[whitelist]",
        f"prefix = [{json.dumps(str(layout.project_root))}]",
    ]

    init_lines = [
        'mkdir -p "$HOME" "$XDG_CONFIG_HOME/direnv" "$XDG_DATA_HOME/direnv" "$XDG_RUNTIME_DIR"',
        'cat >"$XDG_CONFIG_HOME/direnv/direnv.toml" <<\'EOF\'',
        *direnv_toml_lines,
        "EOF",
        f"cd {shell_quote(layout.workdir)}",
        'eval "$(direnv export bash)"',
    ]
    init_script = "\n".join(init_lines) + "\n"
    LOGGER.debug("Prepared init script contents:\n%s", init_script)
    return init_script


def build_rcfile() -> str:
    rcfile_lines = [
        f"source {shell_quote(CONTAINER_INIT_PATH)}",
        'eval "$(direnv hook bash)"',
    ]
    rcfile = "\n".join(rcfile_lines) + "\n"
    LOGGER.debug("Prepared rcfile contents:\n%s", rcfile)
    return rcfile


def build_command_entrypoint() -> str:
    lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        f"source {shell_quote(CONTAINER_INIT_PATH)}",
        'exec "$@"',
    ]
    script = "\n".join(lines) + "\n"
    LOGGER.debug("Prepared command entrypoint contents:\n%s", script)
    return script


def build_container_env(
    identity: ContainerIdentity,
    container_path: str,
    default_extra_env: dict[str, str],
    extra_env: dict[str, str],
) -> dict[str, str]:
    container_env = {
        "CONTAINER_SHELL": "1",
        "HOME": str(identity.home_dir),
        "USER": identity.user_name,
        "LOGNAME": identity.user_name,
        "XDG_CONFIG_HOME": str(identity.xdg_config_home),
        "XDG_DATA_HOME": str(identity.xdg_data_home),
        "XDG_RUNTIME_DIR": str(identity.runtime_dir),
        "PATH": f"{container_path}:{SYSTEM_CONTAINER_PATH}",
    }
    container_env.update(default_extra_env)
    container_env.update(extra_env)
    LOGGER.debug("Prepared container environment: %s", container_env)
    return container_env


def format_command(command: list[str]) -> str:
    return shlex.join(command)


def handle_cleanup_error(function: object, path: str, excinfo: object) -> None:
    del function, excinfo
    target = Path(path)
    try:
        os.chmod(target, 0o700)
    except OSError:
        pass
    try:
        shutil.rmtree(target)
    except OSError:
        try:
            target.unlink()
        except OSError:
            LOGGER.debug("Leaving temporary path behind after cleanup failure: %s", target)


def cleanup_scratch(temp_root: Path) -> None:
    if not temp_root.exists():
        return
    try:
        shutil.rmtree(temp_root, onexc=handle_cleanup_error)
    except TypeError:
        shutil.rmtree(temp_root, onerror=handle_cleanup_error)
    except OSError as exc:
        LOGGER.warning("Failed to remove temporary container-shell directory %s: %s", temp_root, exc)


def add_tty_flags(command: list[str]) -> None:
    if sys.stdin.isatty():
        command.append("-i")
    if sys.stdout.isatty():
        command.append("-t")


def build_podman_command(
    args: argparse.Namespace,
    layout: ShellLayout,
    mounts: list[MountSpec],
    *,
    identity: ContainerIdentity,
    container_env: dict[str, str],
    container_command: list[str],
) -> list[str]:
    command = [
        "podman",
        "run",
        "--rm",
    ]
    add_tty_flags(command)
    command.extend(
        [
            "--hostname",
            "container-shell",
            "--userns=keep-id",
            "--user",
            f"{identity.uid}:{identity.gid}",
            "--group-add",
            "keep-groups",
            "--hostuser",
            identity.user_name,
            "--workdir",
            str(layout.workdir),
        ]
    )

    for key, value in container_env.items():
        command.extend(["-e", f"{key}={value}"])

    for mount in mounts:
        command.extend(["-v", mount.podman_arg()])

    command.append(args.image)
    if container_command:
        command.extend(["bash", str(CONTAINER_COMMAND_PATH), *container_command])
    else:
        command.extend(["bash", "--rcfile", str(CONTAINER_RCFILE_PATH), "-i"])
    return command


def normalize_returncode(returncode: int) -> int:
    if returncode < 0:
        return 128 + abs(returncode)
    return returncode


def run(argv: list[str]) -> int:
    args = parse_args(argv)
    configure_logging(args.debug)
    LOGGER.debug("Parsed CLI arguments: %s", args)

    layout = build_layout(args)

    wrapped_devenv_bin = required_env("CONTAINER_SHELL_WRAPPED_DEVENV_BIN")
    container_tools_path = required_env("CONTAINER_SHELL_CONTAINER_TOOLS_PATH")
    container_path = f"{wrapped_devenv_bin}:{container_tools_path}"
    LOGGER.debug("Container PATH prefix: %s", container_path)

    identity = build_identity(os.getuid(), os.getgid())
    extra_mounts = collect_extra_mounts(args, layout.project_root)
    auto_mount_targets = built_in_mount_targets(layout, identity).union(mount.target for mount in extra_mounts)
    host_cert_bundle_mount, default_extra_env = detect_host_cert_bundle(auto_mount_targets)
    if host_cert_bundle_mount is not None:
        extra_mounts.append(host_cert_bundle_mount)
    ensure_mount_sources(extra_mounts)
    validate_extra_mount_targets(layout, identity, extra_mounts)
    LOGGER.debug("Resolved extra mounts: %s", extra_mounts)

    extra_env = collect_extra_env(args)
    container_command = normalize_command(args.command)
    LOGGER.debug("Resolved container command: %s", container_command)

    temp_root = Path(tempfile.mkdtemp(prefix="container-shell-"))
    try:
        scratch = create_host_scratch(temp_root, identity, layout, extra_mounts)
        scratch.init_script.write_text(build_init_script(layout), encoding="utf-8")
        scratch.rcfile.write_text(build_rcfile(), encoding="utf-8")
        scratch.command_entrypoint.write_text(build_command_entrypoint(), encoding="utf-8")
        LOGGER.debug("Wrote temporary init files under %s", temp_root)

        mounts = build_mounts(layout, scratch, identity, extra_mounts)
        container_env = build_container_env(identity, container_path, default_extra_env, extra_env)
        command = build_podman_command(
            args,
            layout,
            mounts,
            identity=identity,
            container_env=container_env,
            container_command=container_command,
        )

        LOGGER.debug("Podman bind mounts: %s", [mount.podman_arg() for mount in mounts])
        LOGGER.debug("Podman command: %s", format_command(command))

        LOGGER.info("Launching container-shell with image %s", args.image)
        completed = subprocess.run(command, check=False)
        LOGGER.debug("Podman exited with return code %s", completed.returncode)
        return normalize_returncode(completed.returncode)
    finally:
        cleanup_scratch(temp_root)


def main(argv: list[str] | None = None) -> int:
    try:
        return run(sys.argv[1:] if argv is None else argv)
    except KeyboardInterrupt:
        return 130
    except ContainerShellError as exc:
        print(f"container-shell: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
