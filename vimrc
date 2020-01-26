set nocompatible              " be iMproved, required
filetype off                  " required

set shell=/usr/local/bin/zsh

" set the runtime path to include Vundle and initialize
set rtp+=~/.dotfiles/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

" Git commands from inside vim
Plugin 'tpope/vim-fugitive' " plugin on GitHub repo

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'

"" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" ^ faster HTML code editing

" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'

" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'

" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"Plugin 'ascenator/L9', {'name': 'newL9'}

" Solarized color theme
Plugin 'lifepillar/vim-solarized8'

" One Dark color theme
Plugin 'joshdick/onedark.vim'

" Darkula color theme
Plugin 'doums/darcula'

" autocompletion engine
Plugin 'Valloric/YouCompleteMe'

" Better Python Code Folding
Plugin 'tmhedberg/SimpylFold'

" PEP8 Python indenting
Plugin 'vim-scripts/indentpython.vim'

" Improved Python syntax highlighting
Plugin 'vim-syntastic/syntastic'

" PEP8 linting
Plugin 'nvie/vim-flake8'

" File-tree navigation sidebar
Plugin 'scrooloose/nerdtree'

" Superior code commenting
Plugin 'scrooloose/nerdcommenter'

" Move text up/down/left/right with <A-h/j/k/l>
Bundle 'matze/vim-move'
let g:move_map_keys = 0
set <F20>=j
set <F21>=k
set <F22>=h
set <F23>=l
vmap <F20> <Plug>MoveBlockDown
vmap <F21> <Plug>MoveBlockUp
vmap <F22> <Plug>MoveBlockLeft
vmap <F23> <Plug>MoveBlockRight
nmap <F20> <Plug>MoveLineDown
nmap <F21> <Plug>MoveLineUp
nmap <F22> <Plug>MoveLineLeft
nmap <F23> <Plug>MoveLineRight

" Quoting/parenthesizing made simple
Plugin 'tpope/vim-surround'

" Repeat plugin maps with '.'
Plugin 'tpope/vim-repeat'

" A much better status line at the bottom
" Plugin 'vim-airline/vim-airline'
" let g:airline_theme='onedark'
" Another option:
Plugin 'itchyny/lightline.vim'
let g:lightline = {
            \ 'colorscheme': 'onedark',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'fugitive' ],
            \             [ 'readonly', 'filename', 'modified' ] ],
            \   'right': [ [ 'lineinfo' ],
            \              [ 'percent' ],
            \              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'fugitive#head'
            \ },
            \ 'component': {
            \   'charvaluehex': '0x%B'
            \ },
            \ }

" Show git diff in gutter
Plugin 'airblade/vim-gitgutter'

" Code snippets
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
" alternate: https://github.com/SirVer/ultisnips

" Better copy/paste
" Plugin 'vim-scripts/YankRing.vim'

" All of your Plugins must be added before the following line
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
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


"***************************************************************
" Personal Settings
"***************************************************************
set modelines=0     " prevent secuirty exploits via modelines, which I never use

" Indentation settings (spaces are better than tabs)
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab       " real programmers use spaces, not tabs
set smarttab
set autoindent      " Copy indent from current line when starting a new line
set smartindent     " Do smart autoindenting when starting a new line
set cindent         " Stricter indenting rules for C files

" Search settings
set hlsearch        " Highlight search results
set incsearch       " Incremental search; jump to match as you type
set ignorecase      " Ignore case when searching
set smartcase       " Override ignorecase when search pattern has uppercase

" Display settings
syntax on           " syntax highlighting
set laststatus=2    " make room for custom status line
set cursorline      " Highlight current line
set showmatch       " Show matching brackets when cursor on them
set showcmd         " Show command in bottom bar
set number          " Show line numbers
set ruler           " Show line # and column at bottom
set scrolloff=3     " Set lines visible around cursor when scrolling
set wrap            " Soft-wrap lines
set background=dark
if has('gui_running')
    colorscheme solorized8_high
else
    set t_Co=256
    colorscheme onedark
endif

" Change cursor based on mode
let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
"Cursor settings:
"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

" Editor Settings ======================================================
if has('mouse')
    set mouse=a     " Enable mouse usage (all modes)
endif
set encoding=utf-8  " Make sure vim works with python3 files
set backspace=indent,eol,start  " make backspace behave like normal again
set clipboard^=unnamed,unnamedplus  " use system clipboard by default
set history=500     " Sets how many lines of history Vim has to remember
set autowrite       " Automatically save before commands like :next and :make
set autoread        " update automatically when a file is changed from the outside
set hidden          " Hide buffers when they are abandoned (vs. closing them)
set nrformats-=octal    " ignore octal numbers for Ctrl-A/X (confusing)
set timeout timeoutlen=1500 ttimeoutlen=100 " Key Mapping and Keycode timeouts
set wildmenu        " show tab-completions in command line
set wildmode=list:longest   " show all completions, sorted by longest match
set ttyfast         " fast terminal connection, helps with copy/paste
set undofile        " create <filename>.un~ files to persist undo information
command W w !sudo tee % > /dev/null " :W to sudo-save

" Delete trailing white space on save, useful for some filetypes ;)
fun! StripTrailingWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre 
                \ *.php,*.cls,*.java,*.rb,*.md,*.c,*.cpp,*.cc,*.h,*.js,*.py,*.wiki,*.sh,*.coffee 
                \ :call StripTrailingWhitespace()
endif

" Put these in an autocmd group, so that you can revert them with:
" `:augroup vimStartup | au! | augroup END`
augroup vimStartup
    au!
    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                \ |   exe "normal! g`\""
                \ | endif
    " Python PEP8 indentation
    au BufNewFile,BufRead *.py
                \ set tabstop=4
                \ set softtabstop=4
                \ set shiftwidth=4
                \ set textwidth=79
                \ set expandtab
                \ set autoindent
                \ set fileformat=unix
                \ retab
    " Custom indent for web development
    au BufNewFile,BufRead *.js, *.html, *.css
                \ set tabstop=2
                \ set softtabstop=2
                \ set shiftwidth=2
                \ retab
    "Custom Filetype associations
    au BufNewFile,BufRead *.json    set filetype=javascript
augroup END


" Custom Keyboard commands ==============================================
let mapleader="\<space>"    " Custom <leader> key

" Quick escape from insert mode
inoremap jj <ESC>

" Fast saving
nnoremap <leader>w :w!<cr>

" Clear search highlighting
nnoremap <silent> <leader>n :nohl<cr>

" Insert blank line above cursor
nnoremap <leader><cr> m`O<esc>``

" Toggle line numbers
nnoremap <leader>1 :set number!<CR>

" Toggle relative line numbers
nnoremap <leader>0 :set relativenumber!<cr>

" Easier code folding
nnoremap <leader>f za

" auto-format indentation of the current paragraph
nnoremap <leader>q gqip

" Reselect text that was just pasted, so I can perform commands on it
nnoremap <leader>v V`]

" Make tab move to matching brackets
nnoremap <tab> %
vnoremap <tab> %

" Cursor up/down visual lines (if wrapped) instead of text lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" Show and switch buffers easily
nnoremap <leader>b :ls<cr>:buffer 

" Toggle display of NERDTree navigation panel
nnoremap <F6> :NERDTreeToggle<cr>
vnoremap <F6> :NERDTreeToggle<cr>

" Smart way to move between windows
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" Indent/unindent shortcut like vscode
nnoremap <silent> <leader>] >>
nnoremap <silent> <leader>[ <<
vnoremap <silent> <leader>] >gv
vnoremap <silent> <leader>[ <gv

" Insert a date/timestamp
nnoremap <F2> "=strftime("%a, %d %b %Y %H:%M:%S %z")<cr>P
inoremap <F2> <C-R>=strftime("%a, %d %b %Y %H:%M:%S %z")

" Run this file in terminal (if it's a Python file)
autocmd FileType python nnoremap <buffer> <F5> :exec '!clear; python' shellescape(@%, 1)<cr>

" Make it easy to edit the vimrc file
nnoremap <leader>ev :vsplit $MYVIMRC<cr>

" Reload vimrc file (update vim behavior based on vimrc changes)
nnoremap <leader>sv :source $MYVIMRC<cr>


" Plugin-specific:  ======================================================

let g:SimpylFold_docstring_preview=1    " show docstring for folded code

" YouCompleteMe improvements
let g:ycm_autoclose_preview_window_after_completion=1
noremap <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Make python code look pretty
let python_highlight_all=1

" NERDComment settings
let g:NERDSpaceDelims = 1       " Add spaces after comment delimiters by default
let g:NERDCompactSexyComs = 1   " Use compact syntax for prettified multi-line comments
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Custom C comment format
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
nnoremap <leader>/ :call NERDComment(0,"toggle")<CR>
vnoremap <leader>/ :call NERDComment(0,"toggle")<CR>

let NERDTreeIgnore=['\.py[co]$', '\~$'] "ignore files in NERDTree

