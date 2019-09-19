set nocompatible              " be iMproved, required
filetype off                  " required

set shell=/usr/local/bin/bash

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" ^ a wrapper for git

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

" Toggle Comments for blocks of code
"Plugin 'tpope/vim-commentary'

" autocompletion engine
"Plugin 'Valloric/YouCompleteMe'

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

" Custom <leader> key
" let mapleader=","
nmap <space> <leader>
vmap <space> <leader>

" Fast saving
nnoremap <leader>w :w!<cr>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" make backspace behave like normal again
set backspace=indent,eol,start

" easier formatting of paragraphs
" vnoremap Q gq
" nnoremap Q gqap

" Real programmers use spaces, not TABs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab
set smarttab

" Search settings
set hlsearch        " Highlight search results
set incsearch       " Incremental search; jump to match as you type
set ignorecase      " Ignore case when searching
set smartcase       " Override ignorecase when search pattern has uppercase

setlocal spell spelllang=en_us " Enable spell-check with English language
set encoding=utf-8

syntax on           " syntax highlighting
set cursorline      " Highlight current line
set showmatch       " Show matching brackets when cursor on them
set showcmd         " Show command in bottom bar
set number          " Show line numbers
set ruler           " Show line # and column at bottom
set scrolloff=5     " Set lines visible around cursor when scrolling
set wrap            " Soft-wrap lines
set autoindent      " Copy indent from current line when starting a new line
set smartindent     " Do smart autoindenting when starting a new line
set autowrite		" Automatically save before commands like :next and :make
set hidden		    " Hide buffers when they are abandoned (vs. closing them)
set mouse=a		    " Enable mouse usage (all modes)
set history=500     " Sets how many lines of history VIM has to remember
set autoread        " update automatically when a file is changed from the outside
set background=dark
colorscheme solarized8_high

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

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal



"Filetype associations
au BufNewFile,BufRead *.json    set filetype=javascript

" Code block commenting: toggle with '<leader>cc'
let s:comment_map = {
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }
function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " "
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction
nnoremap <leader>cc :call ToggleComment()<cr>
vnoremap <leader>cc :call ToggleComment()<cr>

" Delete trailing white space on save, useful for some filetypes ;)
fun! StripTrailingWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre *.php,*.cls,*.java,*.rb,*.md,*.c,*.cpp,*.cc,*.h,*.js,*.py,*.wiki,*.sh,*.coffee :call StripTrailingWhitespace()
endif

" Put these in an autocmd group, so that you can revert them with:
" ":augroup vimStartup | au! | augroup END"
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

augroup END

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Key Mapping and Keycode timeouts
set timeout timeoutlen=1000 ttimeoutlen=100

" Clear search highlighting
nnoremap <silent> <leader><space> :noh<cr>

" Insert blank line at cursor
nnoremap <leader><cr> O<esc>

" Toggle line numbers
nnoremap <leader>1 :set number!<CR>

" Smart way to move between windows
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" Run this file in terminal (if it's a Python file)
autocmd FileType python nnoremap <buffer> <F5> :exec '!clear; python' shellescape(@%, 1)<cr>

" Make it easy to edit the vimrc file
nnoremap <leader>ev :split $MYVIMRC<cr>

" Reload vimrc file (update vim behavior based on vimrc changes)
nnoremap <leader>sv :source $MYVIMRC<cr>
