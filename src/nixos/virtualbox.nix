{ pkgs, nixpkgs, self, ... }: 

{
  imports = [
    <nixpkgs/nixos/modules/installer/virtualbox-demo.nix> 
  ];
}
