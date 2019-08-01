# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# use the `dotfile` alias for managing config
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# User specific aliases and functions
set -o vi

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
			git ls-files --error-unmatch "$file" >/dev/null 2>&1 \
				|| >&2 echo " untracked" \
				&& git --no-pager log -1 --date=short --format=" %ad %<(25,trunc)%cE >>%s<<" "$file"
		elif [ -d "$file" ]; then
			>&2 echo "directory $file/ ignored"
		else
			>&2 echo "$file not found"
		fi
	done
}

################################################################################
# GraphViz Functions
################################################################################

# Generates a graphviz DOT file indicating all page references in the given directory.
# this needs to be run from the base path that the folders use
printnodes(){
	baseurl="http://local-meridian.smart-square.com"
	>&2 echo printnode $1...
	if [[ $1 == *dbml ]]; then
		echo \"$1\" '[shape=rectangle, style=filled, fillcolor="#999999", fontcolor=black, color=darkslategray, href="'$baseurl/$1'"];'
	else
		echo \"$1\" '[shape=oval, style=filled, fillcolor="#eeeeee", fontcolor=black, color="#999999"];'
	fi	
}
export -f printnodes
grepit() {
	>&2 echo $1...

	# when not an exact match, $2 is the thing being referenced
	# grep -o -R -I "[^=>'\" ]\+`basename $1`" --exclude='*.dot' --exclude='*.svg' --exclude='USAGE' . 2>/dev/null \
	grep -o -R -I "[^=>'\" ]*`basename $1`" --exclude='*.dot' --exclude='*.svg' --exclude='USAGE' . 2>/dev/null \
		| awk -v file="`basename $1`" -v path="$1" -v dirname="`dirname $1`" -F ":" \
		'
		{ 
			printf("# %s\n", $0);
			sub("./", "", $1);
			# separate out the file being referred to on the RHS
			fileref=$2;
			sub(/.*\//,"",fileref);

			if( $2 == path || $2 == "/"path ) {
				# an outside file that points in at a good match of the
				# file we are searching for
				if( ! match($1, dirname ".*") ){
					# this will sometimes be a false positive, as the dirname for
					# subdirectories ("a/b.*") will not match top-level
					# elts ("a/myfile.txt"), so they will look like outside files
					printf("\t\"%s\" [color=red, fontcolor=red, fillcolor=white] # dirname=%s\n", $1, dirname);
					printf("\t\"%s\"->\"%s\" [color=red]\n", $1, path);
				} else {
					printf("\t\"%s\"->\"%s\" [color=black]\n", $1, path);
				}
			} else if ( file == fileref ) {	
				# refer to the same filename but possibly in a different directory
				printf("\t\"%s\"->\"%s\" [style=dashed,color=\"#add8e6\",label=\"%s\",fontcolor=\"#b0c4de\"]\n", $1, path, $2);
			} else {
				printf("# CLOSE MATCH \"%s\"->\"%s\"\n", $1, path, $2);
			}
		}'
}
export -f grepit 

makelist () {
	for file in "$@"; do
		if [ -z "$file" ]; then
			target=.
		else
			target=`basename $file`
		fi

		if [ -d "$file" ]; then
			# print all the edges and some of the nodes
			find "$file" -type f \( ! -name '.*' \) -exec bash -c 'grepit "$0"'  {} \;
			# then overwrite the nodes with definitive styling for the core directory
			find "$file" -type f \( ! -name '.*' \) -exec bash -c 'printnodes "$0"'  {} \;
		else 
			printnodes $file
			grepit $file
		fi
	done
}

makedot() {
	echo "digraph {"
	echo "graph [overlap=false outputorder=edgesfirst];"
	echo "node [fontcolor=slategray,color=slategray];"
	for file in $@; do 
		if [ -z "$file" ]; then
			dir=.
		else
			dir=$file
		fi

		if [ -e "$dir" ]; then
			# remove any duplicate lines
			makelist $dir | awk '!seen[$0]++'
		else 
			>&2 echo "$dir not found"
			exit 1
		fi
	done
	echo "}"
}

################################################################################
# End GraphViz Functions
################################################################################
