# My dotfiles

## Installation

```sh
git clone https://github.com/free-easy/dotfiles --recursive
cd dotfiles
./install.sh
sudo ./install_system.sh
```

Open a new shell.

## NixOS

[src/nixos](./src/nixos/) contains my flake-based NixOS configuration.

To build the OS, run:

```sh
$ nixos-rebuild switch  --flake ./src/nixos#<config name>
```

To update one of the flake inputs, run:

```sh
$ cd ./src/nixos/ && nix flake lock --update-input <input>
# Note that the --update-input can be also used with other `nix flake` commands.
# So you can also run
$ nixos-rebuild switch --flake ./src/nixos#<config name> --update-input <input>
# This let's you update the flake and re-build the OS in one command
```

### Home manager

The provided NixOS configuration already integrates Home Manager. Every NixOS system selects which user to include (together with their home manager configuration).
But Home Manager can also be use standalone. To activate an user home configuration manually.

```sh
$ home-manager switch --flake ./src/nixos#<user>
```

This is useful when debugging home-manager specific Nix expressions.

### Build custom NixOS image

```sh
$ nix build ./src/nixos#<config name>
# E.g. build my VirtualBox
$ nix build ./src/nixos#virtualbox-guest
```

## Dependencies

### i3wm

```sh
sudo apt install \
    i3 \
    network-manager-gnome blueman \
    libnotify-bin \
    imagemagick scrot \
    conky \
    nitrogen \
    rofi \
    pavucontrol pulseaudio \
    dunst \
    fcitx fcitx-googlepinyin \
    x11-xserver-utils \
    light \
    redshift-gtk \
    flameshot xclip xinput xdotool
pip3 install i3ipc autorandr
```

-   Add the user to the video group to allow brightness control

    ```sh
    sudo usermod -aG video <user>
    ```

#### Rofi

Install or [build Rofi](https://github.com/davatorium/rofi/blob/next/INSTALL.md)

```sh
sudo apt install librsvg2-dev \
    libjpeg-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libstartup-notification0-dev \
    flex \
    bison
```

#### Polybar

Install or [compile polybar](https://github.com/polybar/polybar/wiki/Compiling)

If you have to compile polybar, don't forget to install the optional
dependencies

Install fonts

```sh
mkdir -p ~/.local/share/fonts
cp ./src/config/polybar/fonts/* ~/.local/share/fonts/
fc-cache -v
```

Enable bitmap fonts

```sh
sudo ln -s /etc/fonts/conf.avail/70-yes-bitmaps.conf /etc/fonts/conf.d/
sudo unlink /etc/fonts/conf.d/70-no-bitmaps.conf # For disabling no-bitmap setting
sudo dpkg-reconfigure fontconfig
```

#### Picom

[Build picom](https://github.com/yshui/picom#build)

#### wmfocus

```sh
sudp apt install libxcb-keysyms1-dev
cargo install --features i3 wmfocus
```

### Nerd Font

Install the patched Hack font

```sh
curl -Lo hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
mkdir -p ~/.local/share/fonts
unzip hack.zip -d ~/local/share/fonts/
rm -f hack.zip
fc-cache -v
```

### Alacritty

See [installation guide](https://github.com/alacritty/alacritty#pop_os--ubuntu)
