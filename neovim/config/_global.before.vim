
"
" Global Settings
"

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=10

" Show line numbers in the sidebar
set number

" Turn on Syntax Highlighting
syntax enable

" Enable filetype detection
filetype on

set list lcs=tab:\¦\

" NOTE: Required for CSV
" NOTE: Required for lexical
filetype plugin on

" Indentation based on filetype
filetype indent on

" Turn on plugin indenting for git commit messages
filetype indent plugin on

" Leader key
let g:mapleader = "\<Space>"
" let mapleader = ","

" Automatically jump to the end of the text you pasted
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Use persistent undo feature but keep working dir clean
set undofile
set undolevels=10000

" Go back to where you exited
autocmd BufReadPost *
  \if line("'\"") > 0 && line ("'\"") <= line("$") |
  \  exe "normal g'\"" |
  \endif

"
" Use mouse
"
if has('mouse')

  " Enable mouse in all modes
	set mouse=a

  " Start select mode instead of
	set selectmode=mouse,key

  " Show the mouse even when typing
	set nomousehide

  " TODO.document
  " set ttymouse=xterm2
endif

" Preview
" TODO
set completeopt=longest,menu

"
" Formatting
"

set tabstop=2
set softtabstop=2
set shiftwidth=2
set noexpandtab

" Allow for word wrapping.
set wrap
set linebreak
set nolist
set breakindent
set showbreak=╎ " String to put at the start of lines that have been wrapped

" Folding settings.
set foldmethod=indent   " Fold based on indent
set foldnestmax=10      " Deepest fold is 10 levels
set nofoldenable        " Don't fold by default
set foldlevel=1         " This is just what I use

" Show hidden characters.
nmap <leader><leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs.
set listchars+=tab:▸\ ,eol:¬

"
" Paragraph formatting with par.
" NOTE: brew install par
"
if executable('par')
  set textwidth=80
  set formatoptions+=t
  set formatprg=par\ -w80
endif

"
" Turn off search highlighting
" NOTE: Search highlighting doesn't properly work under Cygwin for some unknown
" reason.
"
if !has('win32unix')
  nnoremap <silent> <esc> :noh<cr><esc>
endif

"
" Searching
"
set ignorecase  " searches are case insensitive ...
set smartcase   " ... unless they contain at least one capital letter
