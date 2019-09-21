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

# bash completion (from homebrew)
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
# if [ -r "/usr/local/etc/profile.d/bash_completion.sh" ]; then
# 	. "/usr/local/etc/profile.d/bash_completion.sh"
# 	GIT_PS1_SHOWDIRTYSTATE=true
# 	# export PS1='[\u@mbp \w$(__git_ps1)]\$ '
# 	export PS1='\n\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\n\$ '
# fi

if [ -d "$(brew --prefix)/etc/bash_completion.d" ]; then
	source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
	source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"
	
GIT_PS1_SHOWDIRTYSTATE=true
	export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '

fi

set -o vi


# set the shell to use an escape sequence to set
# the page title
# PS1='\[\e]1;\s\$ \W\a\e]2;\u@\h\a\]'"$PS1"

# if the graphviz package is installed, use this to make (and display) a graph
# of page references as an svg
if [ -x "$(command -v fdp)" ]; then
	showfdp (){
		echo $#
		if [ "$#" -eq 1 ]; then
			basedir=/opt/user-dbml/prod-dbml/pc/docs/WWW/www/0/C/user
			subdir="$1"
		elif [ "$#" -eq 2 ]; then
			basedir=/opt/user-dbml/prod-dbml/pc/docs/WWW/www/0/C/$1
			subdir="$2"
		else
			>&2 echo "fdp [agent|user] dir"
			>&2 echo "Makes graphviz for the given prod-dbml and opens it in chromium."
			return 1
		fi
		filename=${subdir//\//.}.dot
		>&2 echo "making graphviz dotfile from $basedir for $subdir..."
		ssh local-a-www "cd $basedir && makedot $subdir" > $filename \
			&& fdp -T svg -O $filename \
			&& open -a chromium $filename.svg
	}
fi

# show the changes in two branches on a file-bny-file basis,
# <M|D> <path> <short-hash> <commit subject>
git-diff-branch(){
	gitroot=`git rev-parse --show-toplevel`	
	comparebranch="origin/develop"
	case "$#" in
	0)
		branch1=$comparebranch
		branch2=`git branch | grep \* | cut -d ' ' -f2`
		;;
	1)
		branch1=$comparebranch
		branch2=$1
		;;
	2)
		branch1=$1
		branch2=$2
		;;
	*)
		>&2 echo "git-diff-branch [branch1] [branch2]"
		>&2 echo "  If no branches are specified, the current branch will be compared against $comparebranch"
		>&2 echo "  If exactly one branch is specified, the current branch will be compared against $comparebranch"
		return 1;
	esac
	>&2 echo "git-diff-branch $branch1 $branch2..."
	>&2 echo "starting in $gitroot..."
	( cd "$gitroot" && git diff "$branch1" "$branch2" --name-status \
		| awk ' { printf("%s\t%s\t",$1,$2); }
			/^M/ { system("git --no-pager log -1 --format=\"%h\t%s\" " $2); }
			! /^M/ {  cmd=sprintf("git --no-pager log -1 $(git rev-list -n 1 HEAD -- %s) --format=\"%%h\t%%s\"", $2); system(cmd); }' \
		| column -t -s $'\t' )
}

# git log helper
git-hist(){
	for file in "$@"; do 
		if [ -f "$file" ]; then
			printf "%-40s" "$file"
			# because of the symlinks, some files may appear untracked to git
			# so use git ls-files to see if they are tracked
			if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then 
				git --no-pager log -1 --date=short --format=" %ad %<(25,trunc)%cE >>%s<<" "$file"
			else
				>&2 echo " untracked"
			fi
		elif [ -d "$file" ]; then
			>&2 echo "directory $file/ ignored"
		else
			>&2 echo "$file not found"
		fi
	done
}

