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
# this needs to be run from the base path that the folders use
printnodes(){
	baseurl="http://local-meridian.smart-square.com"
	>&2 echo printnode $1...
	if [[ $1 == *dbml ]]; then
		echo \"$1\" '[shape=rectangle, style=filled, fillcolor="#cccccc", fontcolor=black, color=gray13, href="'$baseurl'"];'
	else
		echo \"$1\" '[shape=oval, style=filled, fillcolor="#eeeeee", fontcolor=black, color=gray21];'
	fi	
}
export -f printnodes
grepit() {
	>&2 echo $1...

	# when not an exact match, $2 is the thing being referenced
	grep -o -R -I "[^=>'\" ]\+`basename $1`" --exclude='*.dot' --exclude='*.svg' --exclude='USAGE' . 2>/dev/null \
		| awk -v file="`basename $1`" -v path="$1" -v dirname="`dirname $1`" -F ":" \
		'
		{ 
			printf("# %s\n", $0);
			sub("./", "", $1);
			# separate out the file being referred to on the RHS
			fileref=$2;
			sub(/.*\//,"",fileref);

			if( $2 == path || $2 == "/"path ) {
				printf("\t\"%s\"->\"%s\"\n", $1, path);
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
			find "$file" -type f \( ! -name '.*' \) -exec bash -c 'printnodes "$0"'  {} \;
			find "$file" -type f \( ! -name '.*' \) -exec bash -c 'grepit "$0"'  {} \;
		else 
			grepit $file
		fi
	done
}

makedot() {
	echo "digraph {"
	echo "graph [overlap=false outputorder=edgesfirst];"
	echo "node [fontcolor=gray74,color=gray83];"
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
