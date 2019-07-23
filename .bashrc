# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


# So "ls" will have color
# These LSCOLORS should help make colored ls output conflict less with Solarized
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# use the `dotfile` alias mechanism the same way
# you would `git`, but on config files
# https://news.ycombinator.com/item?id=11070797
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfile config status.showUntrackedFiles no

export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# bash completion (from homebrew)
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
set -o vi

# if the graphviz package is installed, use this to make (and display) a graph
# of page references as an svg
if [ -x "$(command -v fdp)" ]; then
	showfdp (){
		filename=${1//\//.}.dot
		basedir=/opt/user-dbml/prod-dbml/pc/docs/WWW/www/0/C/agent
		>&2 echo "making graphviz dotfile from $basedir for $1..."
		ssh local-a-www "cd $basedir && makedot $1" > $filename \
			&& fdp -T svg -O $filename \
			&& open -a chromium $filename.svg
	}
fi
