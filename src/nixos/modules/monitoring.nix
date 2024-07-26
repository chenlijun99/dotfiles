#
# System monitoring services
#
{...}: {
  services.below = {
    enable = true;
    # Retain for 1 day
    retention.time = 60 * 60 * 24;
  };
}
