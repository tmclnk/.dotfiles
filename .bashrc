# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# use the `dotfile` alias for managing config
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfile config status.showUntrackedFiles no

# User specific aliases and functions
set -o vi

