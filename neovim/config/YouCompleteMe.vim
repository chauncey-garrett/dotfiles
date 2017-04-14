
"
" UltiSnips and YouCompleteMe
"

" Various solutions to integrating UltiSnips, SuperTab, and YouCompleteMe

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Return expands snippet
" Tab cycles through completion
" Space continues with selection (but does not expand snippet)
" https://github.com/Valloric/YouCompleteMe/issues/36#issuecomment-62941322

let g:UltiSnipsExpandTrigger = "<c-tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" Enable tabbing through list of results
function! g:UltiSnips_Complete()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    if pumvisible()
      return "\<C-n>"
    else
      call UltiSnips#JumpForwards()
      if g:ulti_jump_forwards_res == 0
        return "\<TAB>"
      endif
    endif
  endif
  return ""
endfunction

au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"

" Expand snippet or return
let g:ulti_expand_res = 0
function! Ulti_ExpandOrEnter()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res
    return ''
  else
    return "\<return>"
  endif
endfunction

" Set <return> as primary trigger
inoremap <return> <C-R>=Ulti_ExpandOrEnter()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://chauncey.io/ultisnips-youcompleteme-now-if-i-can-just-get-you-two-to-cooperate/

" " Make YCM compatible with UltiSnips (using supertab).
" let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
" let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
" let g:SuperTabDefaultCompletionType = '<C-n>'

" " Better key bindings for UltiSnipsExpandTrigger.
" let g:UltiSnipsExpandTrigger = "<cr>"
" let g:UltiSnipsJumpForwardTrigger = "<c-j>"
" let g:UltiSnipsJumpBackwardTrigger = "<c-k>"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/Valloric/YouCompleteMe/issues/36#issuecomment-171966710

" function! g:UltiSnips_Complete()
  " call UltiSnips#ExpandSnippet()
  " if g:ulti_expand_res == 0
    " if pumvisible()
      " return "\<C-n>"
    " else
      " call UltiSnips#JumpForwards()
      " if g:ulti_jump_forwards_res == 0
        " return "\<TAB>"
      " endif
    " endif
  " endif
  " return ""
" endfunction

" function! g:UltiSnips_Reverse()
  " call UltiSnips#JumpBackwards()
  " if g:ulti_jump_backwards_res == 0
    " return "\<C-P>"
  " endif

  " return ""
" endfunction


" if !exists("g:UltiSnipsJumpForwardTrigger")
  " let g:UltiSnipsJumpForwardTrigger = "<tab>"
" endif

" if !exists("g:UltiSnipsJumpBackwardTrigger")
  " let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
" endif

" au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger     . " <C-R>=g:UltiSnips_Complete()<cr>"
" au InsertEnter * exec "inoremap <silent> " .     g:UltiSnipsJumpBackwardTrigger . " <C-R>=g:UltiSnips_Reverse()<cr>"
