if !empty(glob('~/.vimrc-plugs'))
    source ~/.vimrc-plugs
endif

"***************************************************************
" Personal Settings
"***************************************************************
set nocompatible    " be iMproved
set modelines=0     " prevent secuirty exploits via modelines, which I never use

" Indentation settings
filetype plugin indent on
set autoindent      " Copy indent from current line when starting a new line
set cindent         " Stricter indenting rules for C files
set expandtab       " real programmers use spaces, not tabs
set shiftround
set shiftwidth=4
set smartindent     " Do smart autoindenting when starting a new line
set smarttab
set softtabstop=4
set tabstop=8       " width of normal tab character

" Search settings
set hlsearch        " Highlight search results
set ignorecase      " Ignore case when searching
set incsearch       " Incremental search; jump to match as you type
set smartcase       " Override ignorecase when search pattern has uppercase

" Display settings
colorscheme onedark
set background=dark
set cursorline      " Highlight current line
set laststatus=2    " make room for custom status line
set number          " Show line numbers
set ruler           " Show line # and column at bottom
set scrolloff=3     " Set lines visible around cursor when scrolling
set showcmd         " Show command in bottom bar
set showmatch       " Show matching brackets when cursor on them
set t_Co=256        " full 256 color terminal
set wrap            " Soft-wrap lines
syntax on           " syntax highlighting

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
set autoread        " update automatically when a file is changed from the outside
set autowrite       " Automatically save before commands like :next and :make
set backspace=indent,eol,start  " make backspace behave like normal again
set clipboard^=unnamed,unnamedplus  " use system clipboard by default
set encoding=utf-8  " Make sure vim works with python3 files
set lazyredraw      " Don't redraw during macros (improves performance)
set hidden          " Hide buffers when they are abandoned (vs. closing them)
set history=1000    " Sets how many lines of history Vim has to remember
set nrformats-=octal    " ignore octal numbers for Ctrl-A/X (confusing)
set timeout timeoutlen=1500 ttimeoutlen=100 " Key Mapping and Keycode timeouts
set ttyfast         " fast terminal connection, helps with copy/paste
" set undofile        " create <filename>.un~ files to persist undo information
set wildmenu        " show tab-completions in command line
set wildmode=list:longest   " show all completions, sorted by longest match
command! W w !sudo tee % > /dev/null " :W to sudo-save

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


"****************************************************************************
" Plugin-Specific Settings
"****************************************************************************

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


"****************************************************************************
" CoC - Conqueror of Completion Settings

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nnoremap <leader>rn <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
nnoremap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nnoremap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nnoremap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xnoremap if <Plug>(coc-funcobj-i)
xnoremap af <Plug>(coc-funcobj-a)
onoremap if <Plug>(coc-funcobj-i)
onoremap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nnoremap <silent> <TAB> <Plug>(coc-range-select)
xnoremap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Using CocList
" Show all diagnostics
nnoremap <silent> <leader>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <leader>x  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <leader>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <leader>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <leader>sy  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <leader>p  :<C-u>CocListResume<CR>

" keymap to open yank list
nnoremap <silent> <leader>y  :<C-u>CocList -A --normal yank<cr>

" hi HighlightedyankRegion term=bold ctermbg=11 guibg=#13354A

" add command to format entire document
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Remap for format selected region
vnoremap <leader>f  <Plug>(coc-format-selected)
nnoremap <leader>f  <Plug>(coc-format-selected)

" get correct comment coloring for jsonc config files
autocmd FileType json syntax match Comment +\/\/.\+$+
