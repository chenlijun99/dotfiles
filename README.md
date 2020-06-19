# My dotfiles

## Installation

```sh
git clone https://github.com/free-easy/dotfiles --recursive
cd dotfiles
./install.sh
```
Open a new shell.

## Dependencies

### Nerd Font

Install the patched Hack font

```sh
curl -Lo hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
mkdir -p ~/.fonts
unzip hack.zip -d ~/.fonts/
rm -f hack.zip
```

### Alacritty

See [installation guide](https://github.com/alacritty/alacritty#pop_os--ubuntu)
