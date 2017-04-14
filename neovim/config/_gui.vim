
"
" GUI settings
"

" macVim
if has('macunix')
  set guifont=FiraCode\ Nerd\ Font\ Regular\ 13

" Linux GUI
else
  set guifont=FiraCode\ Nerd\ Font\ Regular\ 13
endif

" Thematic settings for iA Writer clone
set antialias
set guicursor+=a:blinkon0 " disable cursor blink
set guioptions-=r         " kill right scrollbar
set guioptions-=l         " kill left scrollbar
set guioptions-=L         " kill left scrollbar multiple buffers
set guioptions-=T         " kill toolbar
