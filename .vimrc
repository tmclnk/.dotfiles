execute pathogen#infect()

" use matchit to match xml tags with %
" included in standard vim distribution
runtime macros/matchit.vim

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_follow_symlinks = 2
let g:ctrlp_working_path_mode = 0
let g:ctrlp_max_files = 0

set cursorline
set nu
set nowrap
set ignorecase
set smartcase

syntax on

if has('gui_running')
	colorscheme zenburn
	set guifont=Monaco:h14
else
endif

" avantas dbml extensions
autocmd BufRead,BufNewFile *.inc set filetype=xml
autocmd BufRead,BufNewFile *.item set filetype=xml
autocmd BufRead,BufNewFile *.dbml set filetype=xml
autocmd BufRead,BufNewFile *.nest set filetype=xml
autocmd BufRead,BufNewFile *.form set filetype=xml
