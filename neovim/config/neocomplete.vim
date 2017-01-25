
"
" NeoComplete
"

" For some reason this command doesn't work:
"   let g:neocomplete#enable_at_startup = 1
"
" Use this autocmd instead.
" NOTE: https://github.com/Shougo/neocomplete.vim/issues/398
autocmd VimEnter * NeoCompleteEnable

" Disable AutoComplPop.
" NOTE: This option must set it in .vimrc(_vimrc). NOT IN .gvimrc(_gvimrc)!
let g:acp_enableAtStartup = 0

" Use neocomplete.
let g:neocomplete#enable_at_startup = 1

" Use smartcase.
let g:neocomplete#enable_smart_case = 1

" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif

let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><C-l> neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction

" <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

" Close popup by <Space>.
inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
  "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
endif

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" "
" " UltiSnips and NeoComplete
" "

" " NOTE: http://stackoverflow.com/a/22253548
" " Make NeoComplete compatible with UltiSnips (using supertab).
" let g:SuperTabDefaultCompletionType = '<C-n>'

" " Better key bindings for UltiSnipsExpandTrigger.
" let g:UltiSnipsExpandTrigger="<Tab>"
" let g:UltiSnipsJumpForwardTrigger="<C-j>"
" let g:UltiSnipsJumpBackwardTrigger="<C-k>"

" """

" function! g:UltiSnips_Complete()
" call UltiSnips#ExpandSnippet()
" if g:ulti_expand_res == 0
" if pumvisible()
" return "\<C-n>"
" else
" call UltiSnips#JumpForwards()
" if g:ulti_jump_forwards_res == 0
" return "\<Tab>"
" endif
" endif
" endif
" return ""
" endfunction

" " Intercepts YMC mappings so UltiSnips and YMC can work with the above function.
" au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"

" " UltiSnips Options
" let g:UltiSnipsExpandTrigger="<space>"
" let g:UltiSnipsJumpForwardTrigger="<Tab>"
" let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
" " let g:UltiSnipsListSnippets="<C-e>"
" let g:UltiSnipsEditSplit="horizontal"

