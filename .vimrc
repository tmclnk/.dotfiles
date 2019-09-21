execute pathogen#infect()

" use matchit to match xml tags with %
" included in standard vim distribution
" runtime macros/matchit.vim
" packadd matchit

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

set hidden
set confirm

syntax on

" global search, like with superstar
nnoremap gr :grep -ri <cword> *<CR>
nnoremap Gr :grep <cword> %:p:h/*<CR>
nnoremap gR :grep '\b<cword>\b' *<CR>
nnoremap GR :grep '\b<cword>\b' %:p:h/*<CR>

" mac os clipboard access without using "* or "+
" set clipboard=unnamed

if has('gui_running')
	colorscheme zenburn
	set guifont=Monaco:h14
endif

" avantas dbml extensions
autocmd BufRead,BufNewFile *.inc set filetype=xml
autocmd BufRead,BufNewFile *.item set filetype=xml
autocmd BufRead,BufNewFile *.dbml set filetype=xml
autocmd BufRead,BufNewFile *.nest set filetype=xml
autocmd BufRead,BufNewFile *.form set filetype=xml

" set statusline+=%F
set statusline=%F%m%r%h%w\ 
set statusline+=%{fugitive#statusline()}\    
set statusline+=[%{strlen(&fenc)?&fenc:&enc}]
set statusline+=\ [line\ %l\/%L]

" indent
" au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
