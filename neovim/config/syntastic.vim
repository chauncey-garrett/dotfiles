
"
" Syntastic
"

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_open = 1

let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_auto_jump = 1

" Javascript
let g:syntastic_javascript_checkers = ['jshint']

" HTML5
let g:syntastic_html_checkers = [
      \ 'jshint',
      \ 'tidy'
      \ ]

" Ignore @ng html tags
let g:syntastic_html_tidy_ignore_errors=[
      \ "discarding unexpected",
      \ "is not recognized!",
      \ "lacks action",
      \ "proprietary attribute",
      \ "trimming empty <",
      \ "unescaped &"
      \ ]

" SCSS
let g:syntastic_scss_checkers = ['scss_lint']

