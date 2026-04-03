# Example: Incus Dev VM

This example shows how to use the dendritic flake as an input to another flake.
In this case the flake contains a minimal development VM for Incus/LXD.

## What this example does

Creates a minimal NixOS VM with:

* CLI development environment (neovim, shell config, LSPs, formatters)
* SSH server for remote access
* A `dev` user with sudo access

## Usage

```bash
# From this directory
cd examples/incus-dev-vm

# Build the VM configuration
nix build .#nixosConfigurations.incus-dev-vm.config.system.build.toplevel

# Or test in a QEMU VM
nixos-rebuild build-vm --flake .#incus-dev-vm
./result/bin/run-incus-dev-vm-vm
```
