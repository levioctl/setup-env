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

set runtimepath^=~/.vim/bundle/ctrlp.vim,~/.vim/bundle/vim-bling,~/.vim/bundle/grep,~/.vim/bundle/jedi-vim,~/.vim/bundle/vim-flake8,~/.vim/bundle/vim-surround,~/.vim/bundle/rainbow_parentheses.vim
set omnifunc=jedi#completions

let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|.o|.connections|build)$',
  \ 'file': '\v\.(exe|so|dll|pyc|stratolog)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
let g:ctrlp_max_files=300000
let g:ctrlp_use_caching = 1
let g:ctrlp_cache_dir = "/tmp"


"incremental search
set incsearch
"highlight search
set hlsearch
"Press enter to remove search highlight
nnoremap <silent> <ENTER> :noh<cr><esc>
"Spell check
"set spell spelllang=en_us
"highlight clear SpellBad
"highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
"highlight clear SpellCap
"highlight SpellCap term=underline cterm=underline
"highlight clear SpellRare
"highlight SpellRare term=underline cterm=underline
"highlight clear SpellLocal
"highlight SpellLocal term=underline cterm=underline
"Case insensitive search by default
set ignorecase
set smartcase
"Show line numbers
set number
""Exit insert more without delay
set esckeys
set noswapfile

"Mark the tildes as black, it's unnecessary as there are line numbers
hi NonText guifg=black ctermfg=black

"Always display the status bar
set laststatus=2

"DiffOrig command that shows the difference from the file on disk
command DiffOrig let g:diffline = line('.') | vert new | set bt=nofile | r # | 0d_ | diffthis | :exe "norm! ".g:diffline."G" | wincmd p | diffthis | wincmd p
nnoremap <Leader>do :DiffOrig<cr>
nnoremap <leader>dc :q<cr>:diffoff<cr>:exe "norm! ".g:diffline."G"<cr>

"Colors
colorscheme default
hi Search cterm=NONE ctermfg=grey ctermbg=17
set t_Co=256
hi Visual cterm=NONE  ctermbg=39 ctermfg=Black
hi CursorLine cterm=NONE,underline
set cursorline

"Key mappings
noremap <C-h> gT
noremap <C-l> gt
noremap <C-j> :/^\(\s\s\s\s\)*\(class\\|def\)\s<Enter>:noh<Enter>
noremap <C-k> :?^\(\s\s\s\s\)*\(class\\|def\)\s<Enter>:noh<Enter>
vnoremap < <gv " better indentation
vnoremap > >gv " better indentation
nnoremap <C-c> :set cursorline!<CR>
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>
nnoremap <C-e> :tabedit<Enter>:Explore<CR>
"Scroll the autocompletion list
inoremap <expr> j pumvisible() ? '<C-n>' : 'j'
inoremap <expr> k pumvisible() ? '<C-p>' : 'k'
inoremap <expr> <C-d> pumvisible() ? 'j' : <C-d>
inoremap <expr> <C-u> pumvisible() ? 'j' : <C-u>
map - <C-W>-
map = <C-W>+
map _ <C-W><
map + <C-W>>
noremap Q <Nop>
"Use Tab instead of %
nnoremap <tab> %
vnoremap <tab> %
autocmd FileType python map <buffer> <Leader>f :call Flake8()<CR>

"Use ctrl-f to put the search-replace pattern in the command line, with the
"word under the cursor as the replaced string
nnoremap <C-f> :%s/\<<C-r><C-w>\>//g<Left><Left>

"In the quickfix window, <CR> is used to jump to the error under the
"cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

noremap <Leader>c :ccl<Enter>

"File explorer tree style
let g:netrw_liststyle = 3

let g:jedi#show_call_signatures = "1"
let g:jedi#use_tabs_not_buffers = 1

"execute pathogen#infect()
if has("gui_running")
  if has("gui_gtk2")
    set guifont=FreeMono\ 15
  elseif has("gui_photon")
    set guifont=FreeMono:s15
  elseif has("gui_kde")
    set guifont=FreeMono/15/-1/5/50/0/0/0/1/0
  elseif has("x11")
    set guifont=-*-freemono-medium-r-normal-*-*-180-*-*-m-*-*
  else
    set guifont=FreeMono:h15:cDEFAULT
  endif
  colorscheme elflord
endif

set relativenumber

"Rainbow-parentheses
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
