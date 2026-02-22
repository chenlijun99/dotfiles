{
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    shortcuts = {
      ksmserver = {
        "Log Out" = "Alt+Shift+F4,Ctrl+Alt+Del,Log Out";
      };
      kwin = {
        "Activate Window Demanding Attention" = "Ctrl+Alt+A";
        "Edit Tiles" = "Meta+T";
        Expose = "Ctrl+F9";
        ExposeAll = ["Ctrl+F10" "Launch (C)"];
        ExposeClass = "Ctrl+F7";
        "Grid View" = "Meta+G";
        "Kill Window" = "Ctrl+Alt+Esc";
        MoveMouseToCenter = "Meta+F6";
        Overview = "Meta+W";
        "Show Desktop" = "Meta+D";
        ShowDesktopGrid = "Ctrl+F8";
        "Suspend Compositing" = "Alt+Shift+F12";
        "Switch One Desktop Down" = "Meta+Ctrl+Down";
        "Switch One Desktop Up" = "Meta+Ctrl+Up";
        "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
        "Switch One Desktop to the Right" = "Meta+Ctrl+Right";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
        "Switch to Desktop 1" = "Meta+Alt+1";
        "Switch to Desktop 2" = "Meta+Alt+2";
        "Switch to Desktop 3" = "Meta+Alt+3";
        "Switch to Desktop 4" = "Meta+Alt+4";
        "Switch to Desktop 5" = "Meta+Alt+5";
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Backtab";
        "Walk Through Windows of Current Application" = ["Meta+`" "Alt+`"];
        "Walk Through Windows of Current Application (Reverse)" = ["Meta+~" "Alt+~"];
        "Window Close" = "Alt+F4";
        "Window Fullscreen" = "F11";
        "Window Maximize" = "Meta+Shift+F";
        "Window Minimize" = "Meta+PgDown";
        "Window On All Desktops" = "Meta+Ctrl+Shift+A";
        "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
        "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
        "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
        "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
        "Window Operations Menu" = "Alt+F3";
        "Window Quick Tile Bottom" = "Meta+Shift+J";
        "Window Quick Tile Left" = "Meta+Shift+H";
        "Window Quick Tile Right" = "Meta+Shift+L";
        "Window Quick Tile Top" = "Meta+Shift+K";
        "Window to Desktop 1" = "Meta+Alt+!";
        "Window to Desktop 2" = "Meta+Alt+@";
        "Window to Desktop 3" = "Meta+Alt+#";
        "Window to Desktop 4" = "Meta+Alt+$";
        "Window to Desktop 5" = "Meta+Alt+%";
        "Window to Next Screen" = "Meta+Ctrl+Shift+L";
        "Window to Previous Screen" = "Meta+Ctrl+Shift+H";
        disableInputCapture = "Meta+Shift+Esc";
        view_actual_size = [];
        view_zoom_in = "Meta+=";
        view_zoom_out = "Meta+-";
      };
      org_kde_powerdevil = {
        "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
        "Decrease Screen Brightness" = "Monitor Brightness Down";
        "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
        Hibernate = "Hibernate";
        "Increase Keyboard Brightness" = "Keyboard Brightness Up";
        "Increase Screen Brightness" = "Monitor Brightness Up";
        "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
        PowerDown = "Power Down";
        PowerOff = "Power Off";
        Sleep = "Sleep";
        "Toggle Keyboard Backlight" = "Keyboard Light On/Off";
        "Turn Off Screen" = [];
        powerProfile = ["Battery" "Meta+B"];
      };
      plasmashell = {
        "activate application launcher" = ["Meta" "Alt+F1"];
        "activate task manager entry 1" = "Meta+!";
        "activate task manager entry 10" = "Meta+)";
        "activate task manager entry 2" = "Meta+@";
        "activate task manager entry 3" = "Meta+#";
        "activate task manager entry 4" = "Meta+$";
        "activate task manager entry 5" = "Meta+%";
        "activate task manager entry 6" = "Meta+^";
        "activate task manager entry 7" = "Meta+&";
        "activate task manager entry 8" = "Meta+*";
        "activate task manager entry 9" = "Meta+(";
        cycle-panels = "Meta+Alt+P";
        "manage activities" = "Meta+Q";
        "show dashboard" = "Ctrl+F12";
        "stop current activity" = "Meta+S";
      };
      "services/Ghostty.desktop"._launch = "Meta+Ctrl+3";
      "services/clj_multiscreenshot.desktop"._launch = "Print";
      "services/clj_reset_kde_desktop"._launch = "Meta+Shift+R";
      "services/clj_switch_to_ghostty.desktop"._launch = "Meta+3";
      "services/clj_switch_to_dolphin.desktop"._launch = "Meta+1";
      "services/clj_switch_to_firefox.desktop"._launch = "Meta+2";
      "services/clj_switch_to_keepassxc.desktop"._launch = "Meta+4";
      "services/com.mitchellh.ghostty.desktop"._launch = [];
      "services/firefox.desktop"._launch = "Meta+Ctrl+2";
      "services/org.kde.dolphin.desktop"._launch = ["Meta+E" "Meta+Ctrl+1"];
      "services/org.keepassxc.KeePassXC.desktop"._launch = "Meta+Ctrl+4";
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "top";
        height = 30;
        # Floating panel is just distracting and useless.
        # I don't like the aesthetics either.
        floating = false;
        hiding = "none";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              # Don't pin any program
              launchers = [];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    configFile = {
      baloofilerc = {
        # Disable KDE baloo file indexing
        # See https://community.kde.org/Baloo/Configuration
        "Basic Settings".Indexing-Enabled = false;
      };
      dolphinrc = {
        General = {
          # Don't remember tabs from a previously closed Dolphin.
          RememberOpenedTabs = false;
        };
      };
      kdeglobals = {
        KDE.SingleClick = false;
      };

      kwalletrc.Wallet."First Use" = false;
      kwinrc = {
        Compositing.OpenGLIsUnsafe = false;
        Desktops = {
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
        Plugins = {
          # Use fade animation rather than slide animation when switching virtual
          # desktop. The later is too distracting IMHO.
          kwin4_effect_fadedesktopEnabled = true;
          slideEnabled = false;
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
          DelayFocusInterval = 150;
          FocusPolicy = "FocusFollowsMouse";

          NextFocusPrefersMouse = true;
          Placement = "Smart";
          TitlebarDoubleClickCommand = "Maximize";
        };
        Xwayland.Scale = 1;
      };
      kwinrulesrc = {
        "1" = {
          Description = "Application settings for zotero";
          clientmachine = "localhost";
          clientmachinematch = 0;
          desktops = "91d6cb74-a3bb-4f33-a18d-6489ad9a1371";
          desktopsrule = 3;
          wmclass = "zotero";
          wmclasscomplete = true;
          wmclassmatch = 2;
        };
        "2" = {
          Description = "Application settings for zeal";
          clientmachine = "localhost";
          clientmachinematch = 0;
          desktops = "91d6cb74-a3bb-4f33-a18d-6489ad9a1371";
          desktopsrule = 3;
          wmclass = "zeal";
          wmclasscomplete = true;
          wmclassmatch = 2;
        };
        "3" = {
          Description = "Application settings for thunderbird";
          clientmachine = "localhost";
          clientmachinematch = 0;
          desktops = "5aba896a-82fd-402a-a437-ae466558899d";
          desktopsrule = 3;
          wmclass = "thunderbird";
          wmclasscomplete = true;
          wmclassmatch = 2;
        };
        "4" = {
          Description = "Window settings for telegramdesktop";
          clientmachine = "localhost";
          clientmachinematch = 0;
          desktops = "5aba896a-82fd-402a-a437-ae466558899d";
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
          desktops = "5aba896a-82fd-402a-a437-ae466558899d";
          desktopsrule = 3;
          wmclass = "teams-for-linux";
          wmclasscomplete = true;
          wmclassmatch = 2;
        };
        "6" = {
          Description = "Application settings for firefox";
          clientmachine = "localhost";
          clientmachinematch = 0;
          desktops = "91d6cb74-a3bb-4f33-a18d-6489ad9a1371";
          desktopsrule = 3;
          wmclass = "firefox";
          wmclasscomplete = true;
          wmclassmatch = 2;
        };
        "7" = {
          Description = "Application settings for Obsidian";
          desktops = "91d6cb74-a3bb-4f33-a18d-6489ad9a1371";
          desktopsrule = 3;
          wmclass = "obsidian obsidian";
          wmclassmatch = 2;
        };
        General = {
          count = 7;
          rules = "1,2,3,4,5,6,7";
        };
      };

      kxkbrc.Layout = {
        LayoutList = "us";
        Options = "compose:rctrl";
        SwitchMode = "Global";
        Use = true;
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
    };
  };
}
