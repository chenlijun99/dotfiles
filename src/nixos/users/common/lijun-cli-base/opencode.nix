{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      opencode
    ];
  };
  xdg.configFile = {
    "opencode" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/opencode/";
    };
  };
}
