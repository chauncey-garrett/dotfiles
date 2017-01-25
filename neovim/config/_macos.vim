
"
" OS X
"

" Check we're on OS X.
if (system('uname') =~ "darwin")

  "
  " OS X Clipboard
  "

  " Yank text to the OS X clipboard.
  set clipboard=unnamed

  " Preserve indentation while pasting text from the OS X clipboard.
  noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>

  "
  " Marked
  "

  " Open with Marked.
  nnoremap <leader>m :MarkedOpen!<CR>
  " :nnoremap <leader>m :silent !open -a "Marked 2.app" '%:p'<cr>
endif

