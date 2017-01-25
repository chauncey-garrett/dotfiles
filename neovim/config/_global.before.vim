
"
" Global Settings
"

" NOTE: Required for DevIcons
set encoding=utf8

" TODO.comment
set so=10

" Show line numbers in the sidebar
set number

" Turn on Syntax Highlighting
syntax enable

" TODO.comment
filetype on

set list lcs=tab:\¦\

" NOTE: Required for CSV
filetype plugin on

" TODO.comment
filetype indent on

" Turn on plugin indenting for git commit messages.
filetype indent plugin on

" Leader key
let mapleader = "\<Space>"
" let mapleader = ","

" Makes the cursor a pipe in insert-mode, and a block in normal-mode
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

" Automatically jump to the end of the text you pasted
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" Use persistent undo feature but keep working dir clean
if has("persistent_undo")
  set undofile
  set undodir=~/.undodir/
  set undolevels=10000
endif

" Go back to where you exited
if has("autocmd")
  autocmd BufReadPost *
    \if line("'\"") > 0 && line ("'\"") <= line("$") |
    \  exe "normal g'\"" |
    \endif
endif

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
" set completeopt=longest,menu

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

" indent with text
if exists('+breakindent')

  " break character
  " TODO.indentLines?
  set showbreak=╎
  set breakindent
endif

" Folding settings.
set foldmethod=indent   " fold based on indent
set foldnestmax=10      " deepest fold is 10 levels
set nofoldenable        " dont fold by default
set foldlevel=1         " this is just what I use

" Shortcut to rapidly toggle `set list`.
nmap <leader><leader>l :set list!<CR>

" Use the same symbols as TextMate for tabstops and EOLs.
set listchars+=tab:▸\ ,eol:¬

"
" Whitespace
"

function! TrimWhiteSpace()
  %s/\s\+$//e
endfunction

" Delete whitespace from the current line
nnoremap <silent> <Leader>rtws :call TrimWhiteSpace()<CR>

" Delete whitespace on write
" autocmd FileWritePre    * :call TrimWhiteSpace()
" autocmd FileAppendPre   * :call TrimWhiteSpace()
" autocmd FilterWritePre  * :call TrimWhiteSpace()
" autocmd BufWritePre     * :call TrimWhiteSpace()

" Flags is '' to clear highlighting, or is a string to specify what to highlight (one or more characters):
"   e  whitespace at end of line
"   i  spaces used for indenting
"   s  spaces before a tab
"   t  tabs not at start of line
function! ShowWhitespace(flags)
  let bad = ''
  let pat = []
  for c in split(a:flags, '\zs')
    if c == 'e'
      call add(pat, '\s\+$')
    elseif c == 'i'
      call add(pat, '^\t*\zs \+')
    elseif c == 's'
      call add(pat, ' \+\ze\t')
    elseif c == 't'
      call add(pat, '[^\t]\zs\t\+')
    else
      let bad .= c
    endif
  endfor
  if len(pat) > 0
    let s = join(pat, '\|')
    exec 'syntax match ExtraWhitespace "'.s.'" containedin=ALL'
  else
    syntax clear ExtraWhitespace
  endif
  if len(bad) > 0
    echo 'ShowWhitespace ignored: '.bad
  endif
endfunction

function! ToggleShowWhitespace()
  if !exists('b:ws_show')
    let b:ws_show = 0
  endif
  if !exists('b:ws_flags')
    let b:ws_flags = 'eist'  " default (which whitespace to show)
  endif
  let b:ws_show = !b:ws_show
  if b:ws_show
    call ShowWhitespace(b:ws_flags)
  else
    call ShowWhitespace('')
  endif
endfunction

nnoremap <Leader>ws :call ToggleShowWhitespace()<CR>
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen

" au BufEnter * match ExtraWhitespace /\S\zs\s\+$/
" au InsertEnter * match ExtraWhitespace /\S\zs\s\+\%#\@<!$/
" au InsertLeave * match ExtraWhiteSpace /\S\zs\s\+$/

"
" Preserve EOL.
"
let g:PreserveNoEOL = 1

"
" Paragraph formatting with par.
" NOTE: brew install par
"
if executable('par')
  set textwidth=80
  set formatoptions+=t
  set formatprg=par\ -w80
endif

