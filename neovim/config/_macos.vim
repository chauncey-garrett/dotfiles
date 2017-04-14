
"
" macOS
"

" Yank text to the macOS clipboard
set clipboard=unnamed

" Preserve indentation while pasting text from the macOS clipboard
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>
