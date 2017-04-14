
"
" Better Whitespace
" https://github.com/ntpeters/vim-better-whitespace
"

" Remove whitespace on save
autocmd BufEnter * EnableStripWhitespaceOnSave

" Blacklist
let g:better_whitespace_filetypes_blacklist = [
      \ 'diff',
      \ 'gitcommit',
      \ 'help',
      \ 'markdown',
      \ 'mkd',
      \ 'qf',
      \ 'unite'
      \ ]
