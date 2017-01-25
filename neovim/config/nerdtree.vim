
"
" NERDTree
"

" Show hidden files in NERDTree
let NERDTreeShowHidden=1

" Ignore files
let NERDTreeIgnore=[
\   '\.DS_Store$'
\ ]
"\   '\.vim$'

" Close NERDTree on open
let NERDTreeQuitOnOpen = 1

" Open NERDTree automatically when vim starts up and no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close vim if the only window left is NERDTree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Toggle NERDTree
map <Leader>n :NERDTreeToggle<CR>

