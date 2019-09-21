# .bash_profile

# jenv, for setting java environments
if [ -x "$(command -v jenv)" ]; then
	# installed via homebrew
	eval "$(jenv init -)"
elif [ -d $HOME/.jenv/bin ]; then
	# installed manually in home dir 
 	export PATH="$HOME/.jenv/bin:$PATH"
 	eval "$(jenv init -)"
fi


# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/.local/bin:$HOME/bin
PATH="$PATH":/Users/tom/Library/Python/3.7/bin 

export PATH
