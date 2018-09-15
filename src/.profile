# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories
PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# set PATH to include Qt binaries
if [ -d "$HOME/Qt5.7.0/5.7/gcc_64/bin" ]; then
	PATH="$HOME/Qt5.7.0/5.7/gcc_64/bin:$PATH"
fi
if [ -d "$HOME/Qt5.7.0/Tools/QtCreator/bin" ]; then
	PATH="$HOME/Qt5.7.0/Tools/QtCreator/bin/:$PATH"
fi
