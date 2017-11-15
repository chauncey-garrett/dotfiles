
"
" Neomake
"

" Run Neomake on every save
autocmd! BufWritePost * Neomake

" Run Neomake on every save and file open
" NOTE: Doesn't seem to work well.
" autocmd! BufWritePost,BufEnter * Neomake

" Lint as you type (when leaving insert mode)
" https://www.gregjs.com/vim/2015/lint-as-you-type-with-neovim-and-neomake/
" NOTE: Doesn't seem to work well.
" autocmd InsertChange,TextChanged * update | Neomake

" Open the error list automatically but leave the cursor where it is
let g:neomake_open_list = 2

" Only run one linter at a time
let g:neomake_serialize = 1
