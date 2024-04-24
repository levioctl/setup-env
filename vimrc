" Sections below:
" - Vundle
" - Tab/indent stuff
" - Highlighting
" - Search stuff
" - Misc
" - Colors
" - Key mappings
" Plugins:
" - Ctrl-p
" - Rainbow parenthes

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'preservim/nerdtree'
Plugin 'ivyl/vim-bling'
Plugin 'yegappan/grep'
Plugin 'tpope/vim-surround'
Plugin 'frazrepo/vim-rainbow'

call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab/indent stuff
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set colorcolumn=109
set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
set tabstop=4     " a hard TAB displays as 4 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

"Indentation
vnoremap < <gv " better indentation
vnoremap > >gv " better indentation

"Continuation line (whether to indent when pressing Ctrl-o)
set cindent
set cinoptions=(0,u0,U0

"Switch-tab behavior
set switchbuf+=usetab,newtab

" Determines whether to use spaces or tabs on the current buffer.
function TabsOrSpaces()
    if getfsize(bufname("%")) > 256000
        " File is very large, just use the default.
        return
    endif

    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^ "'))

    if numTabs > numSpaces
        "setlocal noexpandtab
    endif
endfunction
autocmd BufReadPost * call TabsOrSpaces()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlighting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Syntax highlighting
syntax enable

"Highlight trailing white spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Show trailing whitepace and spaces before a tab:
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+ /

hi SpellBad ctermbg=000

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Search stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""
"incremental search
set incsearch
"highlight search
set hlsearch
"Case insensitive search by default
set ignorecase
set smartcase

"""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc.
"""""""""""""""""""""""""""""""""""""""""""""""""""

"Show line numbers
set number

""Exit insert mode without delay
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('gui_running')
  colorscheme koehler
  set guifont=FreeMono\ 15
else
  autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
  colorscheme default
  hi Search cterm=NONE ctermfg=grey ctermbg=16
  set t_Co=256
  hi Visual cterm=NONE  ctermbg=39 ctermfg=Black
endif

hi CursorLine cterm=NONE,underline

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Tabs
noremap <C-h> gT
noremap <C-l> gt

"Scroll without moving cursor
noremap <C-j> <C-e>
noremap <C-k> <C-y>

"Jump to next/previous python function
"noremap [[ <S-j>
"noremap ]] <S-k>

nnoremap <C-c> :set cursorline!<CR>

"Scroll the autocompletion list
inoremap <expr> j pumvisible() ? '<C-n>' : 'j'
inoremap <expr> k pumvisible() ? '<C-p>' : 'k'
inoremap <expr> <C-d> pumvisible() ? 'j' : <C-d>
inoremap <expr> <C-u> pumvisible() ? 'j' : <C-u>

"Expanding windows when window is split
map - <C-W>-
map = <C-W>+
map _ <C-W><
map + <C-W>>
noremap Q <Nop>
"Use Tab instead of %
nnoremap <tab> %
vnoremap <tab> %

" Ctrl-t to open a new tab
nnoremap <C-t> :tabedit<CR>

"Use ctrl-f to put the search-replace pattern in the command line, with the
"word under the cursor as the replaced string
nnoremap <C-f> :%s/\<<C-r><C-w>\>//g<Left><Left>

"Close the completion list below
noremap <Leader>c :ccl<Enter>

"Remove search highlight
nnoremap <silent> <ENTER> :noh<cr><esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ctrl-p
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|.connections|build)$',
  \ 'file': '\v\.(exe|dll|pyc|stratolog|logs.racktest|o|so|a)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
let g:ctrlp_max_files=300000
let g:ctrlp_use_caching = 1
let g:ctrlp_cache_dir = "~/.cache/ctrlp.vim"
let g:ctrlp_switch_buffer = 't'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Nerdtree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"File explorer tree style
let g:netrw_liststyle = 3

" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Open the existing NERDTree on each new tab.
autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif

" NERD tre toggle and find
function MyNerdToggle()
    if &filetype == 'nerdtree'
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction

nnoremap <C-\> :call MyNerdToggle()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Rainbow parentheses
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rainbow_active = 1
