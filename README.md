# My dotfiles

## Installation

```sh
git clone https://github.com/free-easy/dotfiles --recursive
cd dotfiles
./install.sh
sudo ./install_system.sh
```

Open a new shell.

## Dependencies

### i3wm

```sh
sudo apt install i3wm conky nitrogen rofi pavucontrol pulseaudio dunst fcitx fcitx-googlepinyin xrandr light
pip3 install autorandr
```

-   Add the user to the video group to allow brightness control

    ```sh
    sudo usermod -aG video <user>
    ```

#### Rofi

Install or [build Rofi](https://github.com/davatorium/rofi/blob/next/INSTALL.md)

```sh
sudo apt install librsvg2-dev libjpeg-dev libxkbcommon-dev libxkbcommon-x11-dev
libstartup-notification0-dev flex bison
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
