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


################################################################################
# GraphViz Functions
################################################################################

# Generates a graphviz DOT file indicating all page references in the given directory.
# use the output from this to generate a visual graph, e.g.
#   accountAdmin > /tmp/accountAdmin.dot
#   fdp -T svg -O /tmp/accountAdmin.dot
grepit() {
	file=`basename $1`
	>&2 echo $1
	if [[ $file == *dbml ]]; then
		echo \"$file\" '[shape=rectangle, style=filled, bgcolor="#ff0000"];'
	else
		echo \"$file\" '[shape=oval];'
	fi	
        fgrep -o -R -I "$file" --exclude="$1" --exclude='*.dot' --exclude='*.svg' --exclude='USAGE' . 2>/dev/null | awk -v file="$file" 'BEGIN { FS = ":" };  { sub(".*/", "", $1); printf("\"%s\"->\"%s\"\n",$1,file) }'
        # fgrep -o -R -I "$file" --exclude="$1" --exclude='*.dot' --exclude='*.svg' --exclude='USAGE' . 2>/dev/null | awk -v file="$file" 'BEGIN { FS = ":" };  { printf("\"%s\"->\"%s\"\n",$1,file) }'
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
			find "$file" -type f \( ! -name '.*' \) -exec bash -c 'grepit "$0"'  {} \;
		else 
			grepit $file
		fi
	done
}

makedot() {
	echo "digraph {"
	for file in $@; do 
		if [ -z "$file" ]; then
			dir=.
		else
			dir=$file
		fi

		makelist $dir | sort | uniq
	done
	echo "}"
}

################################################################################
# End GraphViz Functions
################################################################################
