{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  cachix.enable = false;
  # https://devenv.sh/packages/
  packages = with pkgs; [git age just sops ssh-to-age yq];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    markdownlint.enable = true;
    vdirsyncer = {
      enable = true;
      name = "Update secrets";
      entry = "just secrets-update";
      # No need to monitor YAML file. Those are modified only through sops.
      # So when updated, they're already correctly encrypted.
      files = ".sops.yaml";
      language = "system";
      pass_filenames = false;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
