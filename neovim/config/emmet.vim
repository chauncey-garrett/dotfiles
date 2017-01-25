
"
" Emmet
"

if exists(":Emmet")

  " Only enable Emmet where it's needed.
  let g:user_emmet_install_global = 0

  autocmd FileType html EmmetInstall
  autocmd FileType css EmmetInstall
  autocmd FileType md EmmetInstall
endif

