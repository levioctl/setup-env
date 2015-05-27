filetype plugin indent on
set colorcolumn=109
set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
set tabstop=4     " a hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

cmap w!! w !sudo tee % >/dev/null

"ctrl p
set runtimepath^=~/.vim/bundle/ctrlp.vim
"incremental search
set incsearch
"highlight search
set hlsearch
"Press enter to remove search highlight
nnoremap <silent> <ENTER> :noh<cr><esc>
"Spell check
":set spell spelllang=en_us
"Case insensitive search by default
set ignorecase
"Show line numbers
set number
"Exit insert more without delay
set timeoutlen=0 ttimeoutlen=0
colorscheme koehler

"Mark the tildes as black, it's unnecessary as there are line numbers
hi NonText guifg=black ctermfg=black

"Always display the status bar
set laststatus=2

"DiffOrig command command that shows the difference from the file on disk
command DiffOrig let g:diffline = line('.') | vert new | set bt=nofile | r # | 0d_ | diffthis | :exe "norm! ".g:diffline."G" | wincmd p | diffthis | wincmd p
nnoremap <Leader>do :DiffOrig<cr>
nnoremap <leader>dc :q<cr>:diffoff<cr>:exe "norm! ".g:diffline."G"<cr>
hi Visual cterm=NONE  ctermbg=yellow ctermfg=white
