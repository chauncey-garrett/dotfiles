
"
" Airline
" https://github.com/vim-airline/vim-airline
"

" Display buffers in the Tabbar if there is only one tab
let g:airline#extensions#tabline#enabled = 1

" Define seperators
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" Hide empty sections
let g:airline_skip_empty_sections = 1

" Automatically populate Powerline glyphs
" NOTE: Required by vim-devicons
let g:airline_powerline_fonts = 1

