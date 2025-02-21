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
      "Switch to Desktop 1" = "Meta+Alt+1,Ctrl+F1,Switch to Desktop 1";
      "Switch to Desktop 2" = "Meta+Alt+2,Ctrl+F2,Switch to Desktop 2";
      "Switch to Desktop 3" = "Meta+Alt+3,Ctrl+F3,Switch to Desktop 3";
      "Switch to Desktop 4" = "Meta+Alt+4,Ctrl+F4,Switch to Desktop 4";
      "Switch to Desktop 5" = "Meta+Alt+5,none,Switch to Desktop 5";
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
      "Window to Desktop 1" = "Meta+Alt+!,none,Window to Desktop 1";
      "Window to Desktop 2" = "Meta+Alt+@,none,Window to Desktop 2";
      "Window to Desktop 3" = "Meta+Alt+#,none,Window to Desktop 3";
      "Window to Desktop 4" = "Meta+Alt+$,none,Window to Desktop 4";
      "Window to Desktop 5" = "Meta+Alt+%,none,Window to Desktop 5";
      "Window to Next Screen" = "Meta+Ctrl+Shift+L,none,Window to Next Screen";
      "Window to Previous Screen" = "Meta+Ctrl+Shift+H,none,Window to Previous Screen";
      "view_actual_size" = ",Meta+0,Actual Size";
      "view_zoom_in" = "Meta+=,Meta+=,Zoom In";
      "view_zoom_out" = "Meta+-,Meta+-,Zoom Out";
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
    services = {
      "clj_multiscreenshot.desktop" = {
        _launch = "Print";
      };
      "clj_reset_kde_desktop" = {
        _launch = "Meta+Shift+R";
      };

      "clj_switch_to_dolphin.desktop" = {
        _launch = "Meta+1";
      };
      "clj_switch_to_firefox.desktop" = {
        _launch = "Meta+2";
      };
      "clj_switch_to_alacritty.desktop" = {
        _launch = "Meta+3";
      };
      "clj_switch_to_keepassxc.desktop" = {
        _launch = "Meta+4";
      };
      "org.kde.dolphin.desktop" = {
        _launch = "Meta+E\tMeta+Ctrl+1";
      };
      "firefox.desktop" = {
        _launch = "Meta+Ctrl+2";
      };
      "Alacritty.desktop" = {
        _launch = "Meta+Ctrl+3";
      };
      "org.keepassxc.KeePassXC.desktop" = {
        _launch = "Meta+Ctrl+4";
      };
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
      wmclass = "zotero";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "2" = {
      Description = "Application settings for zeal";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "zeal";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "3" = {
      Description = "Application settings for thunderbird";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_3;
      desktopsrule = 3;
      wmclass = "thunderbird";
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
      wmclass = "telegram-desktop";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "5" = {
      Description = "Application settings for Teams";
      desktops = desktops.Id_3;
      desktopsrule = 3;
      wmclass = "teams-for-linux";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "6" = {
      Description = "Application settings for firefox";
      clientmachine = "localhost";
      clientmachinematch = 0;
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "firefox";
      wmclasscomplete = true;
      wmclassmatch = 2;
    };
    "7" = {
      Description = "Application settings for Obsidian";
      desktops = desktops.Id_2;
      desktopsrule = 3;
      wmclass = "obsidian obsidian";
      wmclassmatch = 2;
    };
    General = {
      # Total number of rules
      count = 7;
      # Order of rules
      rules = "1,2,3,4,5,6,7";
    };
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
  dolphinrc = {
    General = {
      # Don't remember tabs from a previously closed Dolphin.
      RememberOpenedTabs = false;
    };
  };
}
