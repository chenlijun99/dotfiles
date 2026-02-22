# Setup of tools for dendritic pattern
{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  # Set supported systems
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
}
