# AI tooling (wrapped devenv + container shell)
{...}: let
  mkPython = pkgs:
    pkgs.python3.withPackages (ps: [
      ps.pyyaml
    ]);

  mkWrappedDevenv = pkgs: let
    python = mkPython pkgs;
  in
    pkgs.writeShellApplication {
      name = "devenv";
      text = ''
        set -euo pipefail

        export CONTAINER_SHELL_REAL_DEVENV_BIN="${pkgs.lib.getExe pkgs.devenv}"
        exec ${python}/bin/python3 ${./devenv.py} "$@"
      '';
    };

  mkContainerShell = pkgs: wrappedDevenv: let
    python = mkPython pkgs;
  in
    pkgs.writeShellApplication {
      name = "container-shell";
      runtimeInputs = with pkgs; [
        podman
      ];
      text = let
        # Common CLI tools that I and AI agents often use
        containerToolsPath = with pkgs;
          lib.makeBinPath [
            (neovim.override {
              viAlias = false;
              vimAlias = true;
            })
            direnv
            bashInteractive
            coreutils
            curl
            diffutils
            dnsutils
            fd
            file
            findutils
            gawk
            gitMinimal
            gnugrep
            gnused
            iproute2
            iputils
            jq
            less
            netcat-openbsd
            python3
            procps
            ripgrep
            traceroute
            unzip
            uv
            which
            zip
          ];
      in ''
        set -euo pipefail

        export CONTAINER_SHELL_WRAPPED_DEVENV_BIN="${wrappedDevenv}/bin"
        export CONTAINER_SHELL_CONTAINER_TOOLS_PATH="${containerToolsPath}"

        exec ${python}/bin/python3 ${./container-shell.py} "$@"
      '';
    };

  mkContainerShellWrapper = {
    pkgs,
    name,
    containerShell,
    wrappedProgram,
    runtimeInputs ? [],
    containerShellDefaultArgs ? "",
    wrappedProgramArgs ? [],
    wrapperSetup ? "",
    passthroughContainerOptions ? [
      "--pass-env"
      "--env"
      "--extra-mount"
      "--extra-remap"
      "--image"
      "--mount-mode"
      "--mount-root"
      "--write-scope"
    ],
    debugContainerFlag ? "--debug-container",
  }: let
    lib = pkgs.lib;
    python = mkPython pkgs;
    wrapperConfig = pkgs.writeText "${name}-container-shell-wrapper.json" (builtins.toJSON {
      inherit
        name
        wrappedProgram
        containerShellDefaultArgs
        wrappedProgramArgs
        wrapperSetup
        passthroughContainerOptions
        debugContainerFlag
        ;
      bash = lib.getExe pkgs.bash;
      containerShell = lib.getExe containerShell;
    });
  in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs =
        [
          containerShell
          pkgs.coreutils
        ]
        ++ runtimeInputs;
      text = ''
        set -euo pipefail

        exec ${python}/bin/python3 ${./container-shell-wrapper.py} ${lib.escapeShellArg (toString wrapperConfig)} "$@"
      '';
    };
in {
  flake.lib.mkContainerShellWrapper = mkContainerShellWrapper;

  perSystem = {pkgs, ...}: let
    wrappedDevenv = mkWrappedDevenv pkgs;
    containerShell = mkContainerShell pkgs wrappedDevenv;
    aiTools = pkgs.symlinkJoin {
      name = "clj-ai-tools";
      paths = [
        wrappedDevenv
        containerShell
      ];
    };
  in {
    packages = {
      "devenv-wrapper" = wrappedDevenv;
      "container-shell" = containerShell;
      "ai-tools" = aiTools;
    };
  };
}
