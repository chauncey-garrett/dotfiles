
"
" Ctrl-P
"

" Ignore files listed in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

