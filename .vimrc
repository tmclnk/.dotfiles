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
set nowrap
set ignorecase
set smartcase

" avantas
autocmd BufRead,BufNewFile *.inc set filetype=xml
autocmd BufRead,BufNewFile *.item set filetype=xml
autocmd BufRead,BufNewFile *.dbml set filetype=xml
autocmd BufRead,BufNewFile *.nest set filetype=xml
autocmd BufRead,BufNewFile *.form set filetype=xml

set statusline=%{expand('%:~:.')}         " Relative path to the file
set statusline+=%=        " Switch to the right side
set statusline+=%l        " Current line
set statusline+=/         " Separator
set statusline+=%L        " Total lines

set laststatus=2	" always show status line