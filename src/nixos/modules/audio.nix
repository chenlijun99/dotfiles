#
# System-wide configuration related to audio
#
{...}: {
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # High quality BT calls
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [{"device.name" = "~bluez_card.*";}];
        actions = {
          "update-props" = {
            # Auto-connect device profiles on start up or when only partial
            # profiles have connected. Disabled by default if the property
            # is not specified.
            "bluez5.auto-connect" = ["hfp_hf" "hsp_hs" "a2dp_sink"];

            # A2DP <-> HFP profile auto-switching (when device is default output)
            # Available values: false, role (default), true
            # 'role' will switch the profile if the recording application
            # specifies Communication (or "phone" in PA) as the stream role.
            "bluez5.autoswitch-profile" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          {"node.name" = "~bluez_input.*";}
          # Matches all outputs
          {"node.name" = "~bluez_output.*";}
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };
}
