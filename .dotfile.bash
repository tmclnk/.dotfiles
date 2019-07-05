# Contains the `dotfile` alias to be used when using
# the "bare git repo" dotfiles technique, as described
# in this Hacker News Post. Note that they name the alias
# `config` whereas mine is `dotfile.`
# https://news.ycombinator.com/item?id=11070797

# git clone --separate-git-dir=$HOME/.dotfiles https://github.com/tmcoma/.dotfiles $HOME/dotfiles-tmp
# rm -r ~/dotfiles-tmp/
# alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# source this file and then use `config` to manage the files
# like you would with git, so instead of "git add ..." you use
# "dotfile add ..."
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfile config status.showUntrackedFiles no
