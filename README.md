# My dotfiles

## Installation

```sh
git clone https://github.com/free-easy/dotfiles
cd dotfiles
./install.sh
```
Open a new shell.

## TODO

* [x] Move all dotfiles into a src directory. By doing so we remove the ambiguity between dotfiles and project related files.
Thus, in the `install.sh` script, the blacklist won't be needed anymore.
* [ ] Add logic in `install.sh` to handle new files (like incremental install)
