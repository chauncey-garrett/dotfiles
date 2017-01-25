
"
" Ack.vim
"

" Highlight the searched for term.
let g:ackhighlight = 1

" Autoclose the window after opening another result.
let g:ack_autoclose = 1

" Use Dispatch.
"if exists(":Dispatch")
"  let g:ack_use_dispatch = 1
"endif

" Use Ag instead of Ack with Ack.vim.
if executable('ag')
  " let g:ackprg = 'ag --nogroup --nocolor --column'
  let g:ackprg = 'ag --vimgrep'
endif

