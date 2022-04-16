{
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs; [
      latte-dock
    ];

    activation = {
      # Temporary hack to make KDE configurable from Nix
      # See open issue: https://github.com/nix-community/home-manager/issues/607
      #
      # Solutio adapted from https://github.com/kurnevsky/nixfiles/blob/master/modules/kde.nix
      # I added support for nested groups
      kdeConfigs = let
        toValue = v:
          if v == null
          then "--delete"
          else if builtins.isString v
          then "'" + v + "'"
          else if builtins.isBool v
          then "--type bool " + lib.boolToString v
          else if builtins.isInt v
          then builtins.toString v
          else builtins.abort ("Unknown value type: " ++ builtins.toString v);
        configs = import ./kde_config.nix;

        /*
         * Like `mapAttrsToList', but instead of providing the first level
         * attribute name, it recursively enters the set and passes the whole
         * path to the value
         */
        #map (name: f name attrs.${name}) (attrNames attrs);
        mapAttrsToListRecursive = f: set: let
          recurse = path: let
            g = name: value:
              if lib.isAttrs value
              then recurse (path ++ [name]) value
              else f (path ++ [name]) value;
          in
            lib.mapAttrsToList g;
        in
          recurse [] set;

        lines = lib.flatten (lib.mapAttrsToList (file: config_set:
          mapAttrsToListRecursive (path: value: let
            group_options = lib.concatMapStrings (group: " --group \"${group}\"") (lib.init path);
            key = lib.last path;
          in ''
            $DRY_RUN_CMD \
            ${pkgs.libsForQt5.kconfig}/bin/kwriteconfig5 \
            --file ~/.config/'${file}' \
            ${group_options} \
            --key '${key}' \
            ${toValue value}
          '')
          config_set)
        configs);
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
           ${(builtins.concatStringsSep "\n" lines)}
          $DRY_RUN_CMD ${pkgs.libsForQt5.qt5.qttools.bin}/bin/qdbus org.kde.KWin /KWin reconfigure || echo "KWin reconfigure failed"
        '';
    };
  };
}
