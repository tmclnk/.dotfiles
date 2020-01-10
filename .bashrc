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

# tab complete on ssh

_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh

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

killredis() {
    local pid=$(ps aux | grep redis | grep -v grep | awk '{print $2}')
    if [ ! -z "$pid" ]; then
        kill -9 "$pid"
    else
        >&2 echo "redis process not found"
        return 1
    fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

reset_title() { 
    printf '\e]0;\a;'
}

0c() {
    cd /Volumes/avantas/env/prod-dbml/pc/docs/www/0/C;
}


# prints a summary of a ssm jobcode zip file...
summary(){
    total_rows=$(wc -l execution*csv | awk '{print $1}')
    let 'total_rows = total_rows -1'

    workday_errors="$(find . -name '*error.json*' -exec jq 'select(.source=="workday") | .accountId' {} + | wc -l | tr -d '[:space:]')"
    workday_successes=`find . -name '*Response.xml*' | wc -l | awk '{print $1}'`

    ssapi_errors=`find . -name '*error.json' -exec jq 'select(.source=="ss-api") | .accountId' {} + | wc -l | tr -d '[:space:]'`
    ssapi_successes=`find . -name '*ssapi-response.json*' | wc -l | awk '{print $1}'`
    if [ -f errors.json ]; then
        process_errors=`jq '. | length' errors*.json`
    else
        process_errors=0
    fi

    printf '%-20s %8s %8s\n' "" "Success" "Error"
    printf '%-20s %8s %8s\n' "Workday" "$workday_successes" "$workday_errors"
    printf '%-20s %8s %8s\n' "SS-API" "$ssapi_successes" "$ssapi_errors"
    printf '%-20s %8s %8s\n' "Process" "n/a" "$process_errors"

    echo '-----'
    printf '%-20s %8s\n' "Incoming Rows" "$total_rows"
    let "processed_rows = $workday_errors + $ssapi_errors + $ssapi_successes + $process_errors"
    printf '%-20s %8s\n' "Processed Rows" "$processed_rows"

}
