{
  pkgs,
  lib,
  config,
  ...
}: let
  desktops = {
    Id_1 = "32bc0aea-5ba8-4902-ad74-0c5ca0ae5852";
    Id_2 = "91d6cb74-a3bb-4f33-a18d-6489ad9a1371";
    Id_3 = "5aba896a-82fd-402a-a437-ae466558899d";
    Id_4 = "00d0359d-ce4d-4915-a1d9-02fbc4d80919";
    Id_5 = "d76a6054-43cb-445a-9796-ba7896fcaa6e";
    Name_1 = "Main";
    Name_2 = "Docs";
    Name_3 = "Communication";
    Name_4 = "Entertaiment";
    Name_5 = "Misc";
    Number = 5;
    Rows = 1;
  };
in {
  #
  # kwinrc config
  #
  kwinrc = {
    Compositing = {
      OpenGLIsUnsafe = false;
    };
    Desktops = desktops;
    Effect-CoverSwitch = {
      TabBox = false;
      TabBoxAlternative = false;
    };
    Effect-DesktopGrid.BorderActivate = 9;
    Effect-PresentWindows = {
      BorderActivate = 9;
      BorderActivateAll = 9;
      MiddleButtonWindow = 9;
    };
    Windows = {
      # Focus "under" mouse instead of "follow" mouse so that
      # when I switch virtual desktop the window in the target virtual
      # desktop is automatically focused.
      # Before upgrade to KDE 6 this wasn't reequired. Weird.
      #
      # UPDATE: with "FocusUnderMouse" the task switcher behaves strangely.
      # A quick Atl+Tab doesn't alternate between current and old window.
      # It just goes to the next window.
      FocusPolicy = "FocusFollowsMouse";
      DelayFocusInterval = 150;

      NextFocusPrefersMouse = true;
      Placement = "Smart";
      TitlebarDoubleClickCommand = "Maximize";
    };
    Plugins = {
      # Use fade animation rather than slide animation when switching virtual
      # desktop. The later is too distracting IMHO.
      kwin4_effect_fadedesktopEnabled = true;
      slideEnabled = false;
    };
  };
  kdeglobals.KDE.SingleClick = false;
  #
  # Global shortcuts
  #
  kglobalshortcutsrc = {
    kwin = {
      "_k_friendly_name" = "KWin";
      "Activate Window Demanding Attention" = "Ctrl+Alt+A,Ctrl+Alt+A,Activate Window Demanding Attention";
      "Expose" = "Ctrl+F9,Ctrl+F9,Toggle Present Windows (Current desktop)";
      "ExposeAll" = "Ctrl+F10\tLaunch (C),Ctrl+F10\tLaunch (C),Toggle Present Windows (All desktops)";
      "ExposeClass" = "Ctrl+F7,Ctrl+F7,Toggle Present Windows (Window class)";
      "Kill Window" = "Ctrl+Alt+Esc,Ctrl+Alt+Esc,Kill Window";
      "MoveMouseToCenter" = "Meta+F6,Meta+F6,Move Mouse to Center";
      "MoveMouseToFocus" = ",Meta+F5,Move Mouse to Focus";
      "Show Desktop" = "Meta+D,Meta+D,Show Desktop";
      "ShowDesktopGrid" = "Ctrl+F8,Ctrl+F8,Show Desktop Grid";
      "Suspend Compositing" = "Alt+Shift+F12,Alt+Shift+F12,Suspend Compositing";
      "Switch One Desktop Down" = "Meta+Ctrl+Down,Meta+Ctrl+Down,Switch One Desktop Down";
      "Switch One Desktop Up" = "Meta+Ctrl+Up,Meta+Ctrl+Up,Switch One Desktop Up";
      "Switch One Desktop to the Left" = "Meta+Ctrl+Left,Meta+Ctrl+Left,Switch One Desktop to the Left";
      "Switch One Desktop to the Right" = "Meta+Ctrl+Right,Meta+Ctrl+Right,Switch One Desktop to the Right";
      "Switch Window Down" = "Meta+J,Meta+Alt+Down,Switch to Window Below";
      "Switch Window Left" = "Meta+H,Meta+Alt+Left,Switch to Window to the Left";
      "Switch Window Right" = "Meta+L,Meta+Alt+Right,Switch to Window to the Right";
      "Switch Window Up" = "Meta+K,Meta+Alt+Up,Switch to Window Above";
      "Switch to Desktop 1" = "Meta+F1,Ctrl+F1,Switch to Desktop 1";
      "Switch to Desktop 2" = "Meta+F2,Ctrl+F2,Switch to Desktop 2";
      "Switch to Desktop 3" = "Meta+F3,Ctrl+F3,Switch to Desktop 3";
      "Switch to Desktop 4" = "Meta+F4,Ctrl+F4,Switch to Desktop 4";
      "Switch to Desktop 5" = "Meta+F5,none,Switch to Desktop 5";
      "Walk Through Windows" = "Alt+Tab,Alt+Tab,Walk Through Windows";
      "Walk Through Windows (Reverse)" = "Alt+Shift+Backtab,Alt+Shift+Backtab,Walk Through Windows (Reverse)";
      "Window Close" = "Alt+F4,Alt+F4,Close Window";
      "Window Fullscreen" = "F11,none,Make Window Fullscreen";
      "Window Maximize" = "Meta+Shift+F,Meta+PgUp,Maximize Window";
      "Window Minimize" = "Meta+PgDown,Meta+PgDown,Minimize Window";
      "Window On All Desktops" = "Meta+Ctrl+Shift+A,none,Keep Window on All Desktops";
      "Window Operations Menu" = "Alt+F3,Alt+F3,Window Operations Menu";
      "Window Quick Tile Bottom" = "Meta+Shift+J,Meta+Down,Quick Tile Window to the Bottom";
      "Window Quick Tile Left" = "Meta+Shift+H,Meta+Left,Quick Tile Window to the Left";
      "Window Quick Tile Right" = "Meta+Shift+L,Meta+Right,Quick Tile Window to the Right";
      "Window Quick Tile Top" = "Meta+Shift+K,Meta+Up,Quick Tile Window to the Top";
      "Window to Desktop 1" = "Meta+Shift+F1,none,Window to Desktop 1";
      "Window to Desktop 2" = "Meta+Shift+F2,none,Window to Desktop 2";
      "Window to Desktop 3" = "Meta+Shift+F3,none,Window to Desktop 3";
      "Window to Desktop 4" = "Meta+Shift+F4,none,Window to Desktop 4";
      "Window to Desktop 5" = "Meta+Shift+F5,none,Window to Desktop 5";
      "Window to Next Screen" = "Meta+Ctrl+Shift+L,none,Window to Next Screen";
      "Window to Previous Screen" = "Meta+Ctrl+Shift+H,none,Window to Previous Screen";
      "view_actual_size" = ",Meta+0,Actual Size";
      "view_zoom_in" = "Meta+=,Meta+=,Zoom In";
      "view_zoom_out" = "Meta+-,Meta+-,Zoom Out";
    };
    lattedock = {
      "_k_friendly_name" = "Latte Dock";
      "activate entry 1" = "Meta+1,Meta+1,Activate Entry 1";
      "activate entry 10" = "Meta+0,Meta+0,Activate Entry 10";
      "activate entry 2" = "Meta+2,Meta+2,Activate Entry 2";
      "activate entry 3" = "Meta+3,Meta+3,Activate Entry 3";
      "activate entry 4" = "Meta+4,Meta+4,Activate Entry 4";
      "activate entry 5" = "Meta+5,Meta+5,Activate Entry 5";
      "activate entry 6" = "Meta+6,Meta+6,Activate Entry 6";
      "activate entry 7" = "Meta+7,Meta+7,Activate Entry 7";
      "activate entry 8" = "Meta+8,Meta+8,Activate Entry 8";
      "activate entry 9" = "Meta+9,Meta+9,Activate Entry 9";
      "clear-history" = "none,none,Clear Clipboard History";
      "new instance for entry 1" = "Meta+Ctrl+1,Meta+Ctrl+1,New Instance for Entry 1";
      "new instance for entry 10" = "Meta+Ctrl+0,Meta+Ctrl+0,New Instance for Entry 10";
      "new instance for entry 2" = "Meta+Ctrl+2,Meta+Ctrl+2,New Instance for Entry 2";
      "new instance for entry 3" = "Meta+Ctrl+3,Meta+Ctrl+3,New Instance for Entry 3";
      "new instance for entry 4" = "Meta+Ctrl+4,Meta+Ctrl+4,New Instance for Entry 4";
      "new instance for entry 5" = "Meta+Ctrl+5,Meta+Ctrl+5,New Instance for Entry 5";
      "new instance for entry 6" = "Meta+Ctrl+6,Meta+Ctrl+6,New Instance for Entry 6";
      "new instance for entry 7" = "Meta+Ctrl+7,Meta+Ctrl+7,New Instance for Entry 7";
      "new instance for entry 8" = "Meta+Ctrl+8,Meta+Ctrl+8,New Instance for Entry 8";
      "new instance for entry 9" = "Meta+Ctrl+9,Meta+Ctrl+9,New Instance for Entry 9";
    };
    plasmashell = {
      "_k_friendly_name" = "Activity switching";
      "activate task manager entry 1" = "Meta+!,Meta+1,Activate Task Manager Entry 1";
      "activate task manager entry 10" = "Meta+),Meta+0,Activate Task Manager Entry 10";
      "activate task manager entry 2" = "Meta+@,Meta+2,Activate Task Manager Entry 2";
      "activate task manager entry 3" = "Meta+#,Meta+3,Activate Task Manager Entry 3";
      "activate task manager entry 4" = "Meta+$,Meta+4,Activate Task Manager Entry 4";
      "activate task manager entry 5" = "Meta+%,Meta+5,Activate Task Manager Entry 5";
      "activate task manager entry 6" = "Meta+^,Meta+6,Activate Task Manager Entry 6";
      "activate task manager entry 7" = "Meta+&,Meta+7,Activate Task Manager Entry 7";
      "activate task manager entry 8" = "Meta+*,Meta+8,Activate Task Manager Entry 8";
      "activate task manager entry 9" = "Meta+(,Meta+9,Activate Task Manager Entry 9";
      "activate widget 117" = "Alt+F1,none,Activate Application Launcher Widget";
      "clear-history" = "none,none,Clear Clipboard History";
      "clipboard_action" = ",Ctrl+Alt+X,Enable Clipboard Actions";
      "cycleNextAction" = "none,none,Next History Item";
      "cyclePrevAction" = "none,none,Previous History Item";
      "edit_clipboard" = "none,none,Edit Contents...";
      "manage activities" = "Meta+Q,Meta+Q,Activities...";
      "next activity" = "none,Meta+Tab,Walk through activities";
      "previous activity" = "none,Meta+Shift+Tab,Walk through activities (Reverse)";
      "repeat_action" = ",Ctrl+Alt+R,Manually Invoke Action on Current Clipboard";
      "show dashboard" = "Ctrl+F12,Ctrl+F12,Show Desktop";
      "show-barcode" = "none,none,Show Barcode...";
      "show-on-mouse-pos" = "none,none,Open Klipper at Mouse Position";
      "stop current activity" = "Meta+S,Meta+S,Stop Current Activity";
      "switch to next activity" = "none,none,Switch to Next Activity";
      "switch to previous activity" = "none,none,Switch to Previous Activity";
      "toggle do not disturb" = "none,none,Toggle do not disturb";
    };
    ksmserver = {
      "Log Out" = "Alt+Shift+F4,Ctrl+Alt+Del,Log Out";
    };
  };
  # Hot keys (custom shortcuts)
  khotkeysrc = {
    Data.DataCount = 4;
    # First 3 are set by KDE by default
    Data_4 = {
      "Comment" = "Comment";
      "DataCount" = 4;
      "Enabled" = true;
      "Name" = "Lijun";
      "SystemGroup" = 0;
      "Type" = "ACTION_DATA_GROUP";
    };
    Data_4Conditions = {
      ConditionsCount = "0";
    };
    Data_4_1 = {
      Comment = "Reconfigure KWin";
      Enabled = true;
      Name = "Reconfigure KWin";
      Type = "SIMPLE_ACTION_DATA";
    };
    Data_4_1Actions = {
      ActionsCount = 1;
    };
    Data_4_1Actions0 = {
      CommandURL = "qdbus org.kde.KWin /KWin reconfigure";
      Type = "COMMAND_URL";
    };
    Data_4_1Conditions = {
      Comment = "";
      ConditionsCount = 0;
    };
    Data_4_1Triggers = {
      Comment = "Simple_action";
      TriggersCount = 1;
    };
    Data_4_1Triggers0 = {
      Key = "Meta+Shift+C";
      Type = "SHORTCUT";
      Uuid = "{ab5c05f7-c0ae-4351-97d0-c40a9a37d501}";
    };
    Data_4_2 = {
      Comment = "Reset KWin";
      Enabled = "true";
      Name = "Reset KDE desktop";
      Type = "SIMPLE_ACTION_DATA";
    };
    Data_4_2Actions = {
      ActionsCount = "1";
    };
    Data_4_2Actions0 = {
      CommandURL = "clj_reset_kde_desktop";
      Type = "COMMAND_URL";
    };
    Data_4_2Conditions = {
      Comment = "";
      ConditionsCount = 0;
    };
    Data_4_2Triggers = {
      Comment = "Simple_action";
      TriggersCount = 1;
    };
    Data_4_2Triggers0 = {
      Key = "Meta+Shift+R";
      Type = "SHORTCUT";
      Uuid = "{d9d82857-c09d-4949-a256-510366145ae1}";
    };
    Data_4_3 = {
      Comment = "Use flameshot";
      Enabled = true;
      Name = "Screenshot";
      Type = "SIMPLE_ACTION_DATA";
    };
    Data_4_3Actions = {
      ActionsCount = 1;
    };
    Data_4_3Actions0 = {
      CommandURL = "clj_multiscreenshot";
      Type = "COMMAND_URL";
    };
    Data_4_3Conditions = {
      Comment = "";
      ConditionsCount = 0;
    };
    Data_4_3Triggers = {
      Comment = "Simple_action";
      TriggersCount = 1;
    };
    Data_4_3Triggers0 = {
      Key = "Print";
      Type = "SHORTCUT";
      Uuid = "{b18fe7ee-b35e-42b5-a4f9-62cf4278838e}";
    };
  };
  #
  # Window rules
  #
  kwinrulesrc = {
    "1" = {
      Description = "Application settings for zotero";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "Navigator Zotero";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "2" = {
      Description = "Application settings for zeal";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "zeal Zeal";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "3" = {
      Description = "Application settings for thunderbird";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_3;
      desktopsrule = 3;
      wmclass = "Mail thunderbird";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "4" = {
      Description = "Window settings for telegramdesktop";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_3;
      desktopsrule = 3;
      title = "Telegram (29)";
      titlematch = 0;
      types = 1;
      wmclass = "telegram-desktop TelegramDesktop";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "5" = {
      Description = "Application settings for Teams";
      desktops = desktops.Id_3;
      desktopsrule = 3;
      wmclass = "teams-for-linux teams-for-linux";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "6" = {
      Description = "Application settings for firefox";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "Navigator firefox";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "7" = {
      Description = "Application settings for slack";
      clientmachine = "localhost";
      desktops = desktops.Id_3;
      desktopsrule = 3;
      wmclass = "slack Slack";
      wmclassmatch = 2;
    };
    "8" = {
      Description = "Application settings for Obsidian";
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "obsidian obsidian";
      wmclassmatch = 2;
    };
    General.count = 8;
  };
  kxkbrc = {
    Layout = {
      LayoutList = "us";
      Options = "compose:rctrl";
      SwitchMode = "Global";
      Use = true;
    };
  };
  #
  # Okular config
  #
  okularpartrc = {
    General = {
      ShellOpenFileInTabs = true;
      ttsEngine = "flite";
    };
    Reviews = {
      "AnnotationTools" = "<tool type=\"highlight\" id=\"1\" name=\"Keywords\"><engine color=\"#ffffff7f\" type=\"TextSelector\"><annotation color=\"#ffffff7f\" type=\"Highlight\"/></engine><shortcut>1</shortcut></tool>,<tool type=\"highlight\" id=\"2\" name=\"Important\"><engine color=\"#ffbbefff\" type=\"TextSelector\"><annotation color=\"#ffbbefff\" type=\"Highlight\"/></engine><shortcut>2</shortcut></tool>,<tool type=\"highlight\" id=\"3\" name=\"Revisit\"><engine color=\"#ffddbbff\" type=\"TextSelector\"><annotation color=\"#ffddbbff\" type=\"Highlight\"/></engine><shortcut>3</shortcut></tool>,<tool type=\"highlight\" id=\"4\" name=\"Disagree\"><engine color=\"#ffff7777\" type=\"TextSelector\"><annotation color=\"#ffff7777\" type=\"Highlight\"/></engine><shortcut>4</shortcut></tool>,<tool type=\"highlight\" id=\"5\" name=\"Ignored\"><engine color=\"#ff888888\" type=\"TextSelector\"><annotation color=\"#ff888888\" type=\"Highlight\"/></engine><shortcut>5</shortcut></tool>,<tool type=\"underline\" id=\"6\"><engine color=\"#ffff7777\" type=\"TextSelector\"><annotation color=\"#ffff7777\" type=\"Underline\"/></engine><shortcut>6</shortcut></tool>,<tool type=\"note-linked\" id=\"7\" name=\"Note\"><engine color=\"#ffffff7f\" type=\"PickPoint\" hoverIcon=\"tool-note\"><annotation icon=\"Note\" color=\"#ffffff7f\" type=\"Text\"/></engine><shortcut>7</shortcut></tool>,<tool type=\"note-inline\" id=\"8\" name=\"Inline Note\"><engine color=\"#ffffff7f\" type=\"PickPoint\" hoverIcon=\"tool-note-inline\" block=\"true\"><annotation color=\"#ffffff7f\" type=\"FreeText\" width=\"1\" font=\"Noto Sans\\,10\\,-1\\,5\\,50\\,0\\,0\\,0\\,0\\,0\\,Regular\"/></engine><shortcut>8</shortcut></tool>,<tool type=\"ink\" id=\"9\"><engine color=\"#ff000000\" type=\"SmoothLine\"><annotation color=\"#ff000000\" type=\"Ink\" width=\"1\"/></engine><shortcut>9</shortcut></tool>,<tool type=\"ink\" id=\"10\" name=\"Important Line\"><engine color=\"#ffbbefff\" type=\"SmoothLine\"><annotation color=\"#ffbbefff\" type=\"Ink\" width=\"3\"/></engine></tool>";
    };
  };
  #
  # KDE panels config
  # plasmashellrc and plasma-org.kde.plasma.desktop-appletsrc together define
  # the panels of KDE. I was not able to find the difference between them
  # though.
  #
  plasmashellrc = {
    PlasmaViews = {
      "Panel 97" = {
        # Floating panel is just distracting and useless.
        # I don't like the aesthetics either.
        floating = 0;
        Defaults.thickness = 28;
      };
    };
  };
  "plasma-org.kde.plasma.desktop-appletsrc" = {
    # System tray
    # We don't keep track of the Applets in the system tray, as that is quite
    # volatile.
    # The system tray is positioned in the top-level panel.
    Containments."102" = {
      activityId = "";
      formfactor = 2;
      immutability = 1;
      location = 3;
      lastScreen = 0;
      plugin = "org.kde.plasma.private.systemtray";
    };
    # Top level panel
    Containments."97" = {
      activityId = "";
      formfactor = 2;
      immutability = 1;
      location = 3;
      lastScreen = 0;
      plugin = "org.kde.panel";
      wallpaperplugin = "org.kde.image";
      General = {
        AppletOrder = "117;100;115;101;111;119";
      };
      Applets = {
        "100" = {
          immutability = 1;
          plugin = "org.kde.plasma.pager";
          Configuration = {
          };
          General = {
            displayedText = "Number";
            showWindowIcons = true;
          };
        };
        "101" = {
          immutability = 1;
          plugin = "org.kde.plasma.systemtray";
          Configuration = {
            SystrayContainmentId = 102;
          };
        };
        "111" = {
          immutability = 1;
          plugin = "org.kde.plasma.digitalclock";

          "Configuration" = {
            Appearance = {
              displayTimezoneAsCode = "";
              displayTimezoneFormat = "FullText";
              showDate = true;
              showSeconds = true;
              showWeekNumbers = true;
            };
          };
        };
        "115" = {
          immutability = 1;
          plugin = "org.kde.plasma.icontasks";
          Configuration = {
            General = {
              # I don't want any pinned program in the icon tasks manager
              launchers = "";
            };
          };
        };
        "117" = {
          immutability = 1;
          plugin = "org.kde.plasma.kickoff";
          Configuration = {
            General = {
              favoritesPortedToKAstats = true;
            };
          };
          Shortcuts = {
            global = "Alt+F1";
          };
        };
        "119" = {
          immutability = 1;
          plugin = "org.kde.plasma.showdesktop";
          Configuration = {
          };
        };
      };
    };
  };
  #
  # Latte dock config
  #
  lattedockrc = {
    UniversalSettings = {
      badges3DStyle = false;
      canDisableBorders = false;
      currentLayout = "Lijun";
      singleModeLayoutName = "Lijun";
      # Global launchers group.
      # I.e. if configured to use the global group, a dock has these applications pinned.
      # Note that some launchers may behave strangely (e.g. firefox), i.e.
      # duplicate launchers entries.
      # Related to https://github.com/NixOS/nixpkgs/issues/38987
      # The only workaround is far is to open the programs and pin them.
      #
      # After all, KDE configs are a mess and this home-manager based config is
      # not intended to be an exact reflection of the working config.
      # It's more a good base on which I can arrive at the desired config in as
      # few steps as possible.
      launchers = lib.concatMapStringsSep "," (app: "applications:" + app) (
        ["org.kde.dolphin.desktop" "firefox.desktop" "Alacritty.desktop"]
        ++ lib.optionals (builtins.elem pkgs.keepassxc config.home.packages)
        ["org.keepassxc.KeePassXC.desktop"]
        ++ lib.optionals (builtins.elem pkgs.obsidian config.home.packages)
        ["obsidian.desktop"]
        ++ lib.optionals (builtins.elem pkgs.zotero config.home.packages)
        ["zotero.desktop"]
      );
      memoryUsage = 0;
      metaPressAndHoldEnabled = true;
      mouseSensitivity = 2;
      screenTrackerInterval = 2500;
      showInfoWindow = true;
      version = 2;
    };
  };
  "latte/Lijun.layout.latte" = {
    Containments."1" = {
      activityId = "";
      byPassWM = false;
      dockWindowBehavior = true;
      enableKWinEdges = false;
      formfactor = 2;
      immutability = 1;
      isPreferredForShortcuts = false;
      location = 4;
      onPrimary = true;
      plugin = "org.kde.latte.containment";
      raiseOnActivityChange = false;
      raiseOnDesktopChange = false;
      settingsComplexity = 4;
      timerHide = 100;
      timerShow = 500;
      viewType = 0;
      visibility = 4;
      wallpaperplugin = "org.kde.image";
      General = {
        # Size of the icons
        iconSize = 36;
        # Margin between icons
        lengthExtMargin = 15;
      };
      Applets = {
        "2" = {
          immutability = 1;
          plugin = "org.kde.latte.plasmoid";
          General = {
            advanced = false;
            autoDecreaseIconSize = false;
            editBackgroundOpacity = "0.5";
            hoverAction = "HighlightWindows";
            iconMargin = 0;
            iconSize = 33;
            panelSize = 5;
            shadowOpacity = 35;
            shadowSize = 40;
            showGlow = false;
            showWindowActions = true;
            shrinkThickMargins = true;
            splitterPosition = 3;
            splitterPosition2 = 4;
            themeColors = "SmartThemeColors";
            zoomLevel = 2;
          };
          Configuration.General = {
            isInLatteDock = true;
            # Use global group launchers.
            # I.e. use the global configuration of pinned applications (in
            # lattedockrc)
            launchersGroup = "Global";
          };
        };
      };
    };
  };
  dolphinrc = {
    General = {
      # Don't remember tabs from a previously closed Dolphin.
      RememberOpenedTabs = false;
    };
  };
}
