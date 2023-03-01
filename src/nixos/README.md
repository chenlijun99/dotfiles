# My NixOS

My multi-device NixOS configuration.

## Structure

* `default.nix`: as you probably know if you're familiar with NixOS, `default.nix` in any folder is the default Nix module that is imported when importing that folder (similar to `index.html`).
* `hardware-configuration.nix`: for most machines, there is an auto-generated file called

```
.
├── flake.lock         # flake lock
├── flake.nix          # flake-based main entrypoint
├── machines           # Machine specific configuration
│   ├── thinkpad-l390-yoga # My ThinkPad L390
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── virtualbox-guest # My VirtualBox guest, that I use to test NixOS
│       └── default.nix
├── modules            # Loose functionality blocks that can be imported by `machines`
│   ├── audio.nix
│   ├── base-gui.nix
│   ├── bluetooth.nix
│   ├── common # Common module used on all machines
│   │   └── ...
│   ├── desktop.nix
│   ├── dev.nix
│   ├── docker.nix
│   └── virtualbox.nix
├── README.md # This README.md
└── users              # User configs that can be imported by `machines`
    ├── common         # Common building blocks shared across users
    │   └── ...
    ├── lijun          # The user that I daily use
    │   └── ...
    ├── lijun-test     # A "stateless" user that resembles the user that I daily use
    │   └── ...
    └── test           # A "stateless" user
        └── ...
```
