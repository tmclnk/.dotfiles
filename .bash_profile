# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

[[ $- == *i* ]] && dotfile config status.showUntrackedFiles no

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

# ORACLE
ORACLE_HOME=/usr/lib/oracle/19.3/client64
PATH=$ORACLE_HOME/bin:$PATH
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_HOME
export LD_LIBRARY_PATH

export PATH
