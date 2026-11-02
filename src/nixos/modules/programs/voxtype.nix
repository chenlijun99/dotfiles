{...}: {
  flake.modules.homeManager.clj-voxtype = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.clj.programs.voxtype;

    # Use the Intel Arc iGPU through Vulkan. This preserves model quality while
    # making inference roughly an order of magnitude faster than the CPU build.
    # OpenVINO on the Intel NPU was tried. With comparable transcripts it was
    # slower than Vulkan: 0.88s for small.en-int8 on NPU versus 0.68s for
    # small.en-q8_0 on Vulkan. OpenVINO also needed custom compiler packaging.
    package = pkgs.voxtype-vulkan;

    # q8_0 keeps small.en's technical-name accuracy while staying close to
    # base.en latency. On the same 14.38s clip: base.en 0.43s, small.en-q8_0
    # 0.68s, and full small.en 0.92s.
    modelPackage = pkgs.fetchurl {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en-q8_0.bin";
      hash = "sha256-Z6F59gjqYRS9P9uQYOditYij+zvQDEOHlxvk0XeVgGc=";
    };

    # The nixpkgs package lacks the OSD frontend. Pin the matching release
    # binary so the OSD does not require a separate upstream nixpkgs closure.
    osdPackage = pkgs.callPackage ../../packages/voxtype-osd-gtk4.nix {};
  in {
    options.clj.programs.voxtype.enable = lib.mkEnableOption "Voxtype speech-to-text" // {default = true;};

    config =
      # Voxtype is Linux-only.
      lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
        assertions = [
          {
            assertion = package.version == osdPackage.version;
            message = "voxtype and voxtype-osd-gtk4 versions must match";
          }
        ];

        home = {
          packages = [osdPackage];

          file.".local/share/voxtype/models/ggml-small.en-q8_0.bin".source = modelPackage;
        };

        services.voxtype = {
          enable = true;
          inherit package;

          # The service PATH is deliberately minimal. Expose the OSD frontend
          # and clipboard tool there so the launcher can find them when spawned
          # by the daemon.
          environment.PATH = lib.makeBinPath [
            osdPackage
            pkgs.coreutils
            pkgs.which
            pkgs.wl-clipboard
          ];

          settings = {
            hotkey = {
              # KWin does not expose key-release events. KDE owns the toggle
              # shortcut, so the built-in evdev hotkey is unnecessary and the
              # user does not need input-group access.
              enabled = false;
              mode = "toggle";
            };

            whisper = {
              model = "ggml-small.en-q8_0.bin";
              language = "en";

              # Multilingual alternative:
              #   model = "large-v3-turbo";
              #   language = ["zh" "en" "it"];
              # On a 14.38s clip, large-v3-turbo measured 3.74s with a fixed
              # language and 7.29s with zh/en/it detection. Both are too slow
              # for routine dictation.

              # Short clips otherwise pay for Whisper's full context window.
              context_window_optimization = true;

              # Streaming emits output through the output chain as it recognizes
              # text. Clipboard output would then replace the clipboard for each
              # segment instead of collecting the complete transcript.
              streaming = false;
            };

            # Correct recurring model and tool-name misspellings after inference.
            text.replacements = {
              "covernatis" = "Kubernetes";
              "graphana" = "Grafana";
              "graphena" = "Grafana";
              "kubernetis" = "Kubernetes";
              "postgre sql" = "PostgreSQL";
            };

            output = {
              # Clipboard output avoids synthetic keystrokes, which can trigger
              # editor mappings or commands in applications such as Neovim.
              mode = "clipboard";

              notification = {
                # Completion sounds provide feedback without retaining transcript
                # text in desktop notifications.
                on_transcription = false;
                on_no_speech = true;
              };
            };

            audio.feedback = {
              enabled = true;
              theme = "subtle";
              volume = 0.7;
            };

            osd = {
              enabled = true;
              frontend = "gtk4";
            };
          };
        };

        # plasma-manager can bind shortcuts to desktop services. The actual
        # Meta+Shift+V binding lives with the other KDE shortcuts.
        xdg.dataFile."applications/voxtype-toggle.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Voxtype Toggle
          Exec=${lib.getExe package} record toggle --clipboard
          Terminal=false
          NoDisplay=true
          StartupNotify=false
        '';

        # Keep downloaded models across rebuilds without persisting meeting
        # recordings.
        home.persistence.${config.clj.impermanence.persistDir}.directories = [
          ".local/share/voxtype/models"
        ];
      };
  };
}
