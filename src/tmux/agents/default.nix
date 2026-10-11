{
  lib,
  python3Packages,
  tmux,
  fzf,
}:
python3Packages.buildPythonApplication {
  pname = "clj-agents";
  version = "0.1.0";

  # Nothing to compile and no packaging backend: the tool is only ever run.
  pyproject = false;
  src = lib.cleanSource ./.;
  dontBuild = true;

  # The CLI shells out to tmux and fzf, so they go on its PATH.
  propagatedBuildInputs = [ tmux fzf ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/clj-agents $out/bin
    cp -r clj_agents $out/libexec/clj-agents/

    # A python entry point rather than a shell wrapper, so startup stays fast.
    cat > $out/bin/clj_agents <<ENTRY
#!${python3Packages.python.interpreter}
import sys

sys.path.insert(0, "$out/libexec/clj-agents")

from clj_agents.cli import main

raise SystemExit(main())
ENTRY
    chmod +x $out/bin/clj_agents

    # Whoever ran the tests in the checkout may have left bytecode behind.
    find $out -name __pycache__ -type d -prune -exec rm -rf {} +

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ${python3Packages.python.interpreter} -m unittest discover -s tests
    runHook postCheck
  '';

  meta = {
    description = "Hook-free coding-agent overview for tmux (scan, popup)";
    longDescription = ''
      Lists every coding-agent pane on a tmux server with its state, and opens a
      picker that previews the real pane. Detection reads the pane title and the
      pane screen only, so nothing is installed into the agents. The detection
      rules are vendored from snirt/agenmux (MIT).
    '';
    license = lib.licenses.mit;
    mainProgram = "clj_agents";
    platforms = lib.platforms.linux;
  };
}
