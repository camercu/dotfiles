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

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
"" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'

" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'

" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"Plugin 'ascenator/L9', {'name': 'newL9'}

Plugin 'lifepillar/vim-solarized8'

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

set wrapmargin=8
set number
set shiftwidth=4		        " vim's shifts using >> represent 4 characters
set tabstop=4			        " tabs you type represent four character positions
set expandtab			        " turn any tab you type into spaces
set ruler			            " an awesome option that
syntax on			            " syntax highlighting
filetype indent plugin on		" turn on a plugin to do most of indenting based on filename

set background=dark
colorscheme solarized8_high

"***********************************************************************************************
set bs=2     " make backspace behave like normal again

" easier formatting of paragraphs
vmap Q gq
nmap Q gqap

" Real programmers don't use TABs but spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

" Make search case insensitive
set hlsearch
set incsearch
set ignorecase
set smartcase

function! RunTestsInFile()
    if(&ft=='php')
        :execute "!" . "/Users/dblack/pear/bin/phpunit -d memory_limit=512M -c /usr/local/twilio/src/php/tests/config.xml --bootstrap /usr/local/twilio/src/php/tests/bootstrap.php " . bufname('%') . ' \| grep -v Configuration \| egrep -v "^$" '
    elseif(&ft=='go')
        exec ":!gp test"
    elseif(&ft=='python')
        exec ":read !" . ". venv/bin/activate; nosetests " . bufname('%') . " --nocapture"
    endif
endfunction

function! RunTestFile()
    if(&ft=='python')
        exec ":!" . ". venv/bin/activate; nosetests " .bufname('%') . " --stop"
    endif
endfunction

" AutoGroups {{{
augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd BufWritePre *.php,*.py,*.js,*.txt,*.hs,*.java,*.md,*.rb :call <SID>StripTrailingWhitespaces()
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2
augroup END
" }}}
" Leader Shortcuts {{{
let mapleader=","
nnoremap <leader>m :silent make\|redraw!\|cw<CR>
nnoremap <leader>w :NERDTree<CR>
nnoremap <leader>u :GundoToggle<CR>
nnoremap <leader>h :A<CR>
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>l :call ToggleNumber()<CR>
nnoremap <leader><space> :noh<CR>
nnoremap <leader>s :mksession<CR>
nnoremap <leader>a :Ag 
nnoremap <leader>c :SyntasticCheck<CR>:Errors<CR>
nnoremap <leader>1 :set number!<CR>
nnoremap <leader>d :Make! 
nnoremap <leader>r :call RunTestFile()<CR>
nnoremap <leader>g :call RunGoFile()<CR>
vnoremap <leader>y "+y
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
inoremap jk <esc>
" }}}

" Searching {{{
set ignorecase          " ignore case when searching
set incsearch           " search as characters are entered
set hlsearch            " highlight all matches
" }}}

set showmatch           " higlight matching parenthesis
set number              " show line numbers
set showcmd             " show command in bottom bar
set nocursorline        " highlight current line

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"if has("autocmd")
"  filetype plugin indent on
"endif

" Show whitespace
" MUST be inserted BEFORE the colorscheme command
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
au InsertLeave * match ExtraWhitespace /\s\+$/

" F5 OPNOTES
nmap <F5> a<C-R>=strftime("%Y-%m-%d %a %H:%M:%S")<CR><Esc>
inoremap <F5> <C-R>=strftime("[" . $USER . "] %Y-%m-%d %a %H:%M:%S: ")<CR>
nnoremap <F5> "=strftime("[" . $USER . "] %Y-%m-%d %a %H:%M:%S: ")"<CR>Pa
