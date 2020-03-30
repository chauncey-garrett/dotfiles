
"
" Emoji
" https://github.com/junegunn/vim-emoji
"

" emoji completion
set completefunc=emoji#complete

" Gitgutter integration
if emoji#available()
  let g:gitgutter_sign_added = emoji#for('small_blue_diamond')
  let g:gitgutter_sign_modified = emoji#for('small_orange_diamond')
  let g:gitgutter_sign_removed = emoji#for('small_red_triangle')
  let g:gitgutter_sign_modified_removed = emoji#for('collision')
endif
