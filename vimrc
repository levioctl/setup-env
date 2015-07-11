filetype plugin indent on
set colorcolumn=109
set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
set tabstop=4     " a hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

cmap w!! w !sudo tee % >/dev/null

"Switch-tab behavior
set switchbuf+=usetab,newtab

"ctrl p
set runtimepath^=~/.vim/bundle/ctrlp.vim,~/.vim/bundle/vim-bling,~/.vim/bundle/grep
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|pyc)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

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

"Mark the tildes as black, it's unnecessary as there are line numbers
hi NonText guifg=black ctermfg=black

"Always display the status bar
set laststatus=2

"DiffOrig command command that shows the difference from the file on disk
command DiffOrig let g:diffline = line('.') | vert new | set bt=nofile | r # | 0d_ | diffthis | :exe "norm! ".g:diffline."G" | wincmd p | diffthis | wincmd p
nnoremap <Leader>do :DiffOrig<cr>
nnoremap <leader>dc :q<cr>:diffoff<cr>:exe "norm! ".g:diffline."G"<cr>

"Colors
colorscheme delek
hi Search cterm=NONE ctermfg=grey ctermbg=17
set t_Co=256
hi Visual cterm=NONE  ctermbg=39 ctermfg=Black
hi CursorLine cterm=NONE,underline
nnoremap <C-c> :set cursorline!<CR>
set cursorline

"Key mappings
noremap <C-h> gT
noremap <C-l> gt
noremap <C-j> <C-e>
noremap <C-k> <C-y>
vnoremap < <gv " better indentation
vnoremap > >gv " better indentation

"File explorer tree style
let g:netrw_liststyle=3

"Use ctrl-f to put the search-replace pattern in the command line, with the
"word under the cursor as the replaced string
:nnoremap <C-f> :%s/\<<C-r><C-w>\>//g<Left><Left>

"In the quickfix window, <CR> is used to jump to the error under the
"cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
