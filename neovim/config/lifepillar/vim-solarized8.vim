"
" Solarized8
" https://github.com/lifepillar/vim-solarized8
" NOTE: colorscheme must be set in after file
"

" Use terminal's base16 colors
" let g:solarized_use16 = 1

" Set terminal background to transparent
let g:solarized_termtrans = 1

" Enable italics
let g:solarized_term_italics = 1

" Possible fix for colors
" https://github.com/lifepillar/vim-solarized8#troubleshooting
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Enable true color support
" https://gist.github.com/XVilka/8346728
set termguicolors
