{writeShellApplication, python3, git, gh}:
writeShellApplication {
  name = "review-session";
  runtimeInputs = [python3 git gh];
  text = ''
    exec python3 ${./.}/bin/review-session "$@"
  '';
}
