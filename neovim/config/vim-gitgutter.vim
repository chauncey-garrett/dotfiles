
"
" Gitgutter
"

" Disable Gitgutter's mappings
" let g:gitgutter_realtime = 1

" Update gitgutter after you stop typing
let g:gitgutter_realtime = 250 " in ms (default is 4000)
let g:gitgutter_eager = 1000 " in ms (default is 4000)

"let g:gitgutter_realtime = 1
"let g:updatetime = 250 " in ms (default is 4000)

" Highlight lines
" let g:gitgutter_highlight_lines = 1

" Keymappings

" Jump to next/previous Hunk
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

" Hunk Add/Revert
nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hr <Plug>GitGutterUndoHunk

" Hunk View
nmap <Leader>hv <Plug>GitGutterPreviewHunk

" Hunk as a Text Object
omap ih <Plug>GitGutterTextObjectInnerPending
omap ah <Plug>GitGutterTextObjectOuterPending
xmap ih <Plug>GitGutterTextObjectInnerVisual
xmap ah <Plug>GitGutterTextObjectOuterVisual<Paste>

