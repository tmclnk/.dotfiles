# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# use the `dotfile` alias for managing config
[[ -f $HOME/.dotfile.bash ]] && . $HOME/.dotfile.bash

# User specific aliases and functions
set -o vi

