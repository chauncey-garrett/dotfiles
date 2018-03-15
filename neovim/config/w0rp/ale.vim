
"
" ALE
" https://github.com/w0rp/ale
"

" Enable Airline integration
let g:airline#extensions#ale#enabled = 1

" Open window on error
let g:ale_open_list = 1

" Only lint on save
let g:ale_lint_on_text_changed = 'normal'

" Automatically close loclist when its buffer is closed
augroup CloseLoclistWindowGroup
  autocmd!
  autocmd QuitPre * if empty(&buftype) | lclose | endif
augroup END
