
"
" Markdown
"

" FormD
if executable('formd')
  nmap <leader>fr :%! formd -r<CR>
  nmap <leader>fi :%! formd -i<CR>
endif

" Markdown2HTML
if executable('mmd')
  nmap <leader>md :%!mmd --to=html --smart --notes --mask --process-html<cr>
endif

"
" Spell checking
"

" Turn on spell checking.
set spell

"
" Git
"

" Insert at the end of the first line in a git commit message.
" autocmd VimEnter * execute "normal A"

"
" Typewriter mode
"

" Keep the focus on the current line
" set scrolloff=999

"
" Miscellaneous
"

" Allow saving of files as sudo when I forgot to start vim using sudo.
" NOTE: http://stackoverflow.com/a/7078429
cmap w!! w !sudo tee > /dev/null %

" Visually select the text that was last edited/pasted.
nmap gV `[v`]

"
" Window splitting
"

" More natural splitting
set splitbelow
set splitright

" Simplify window movement
" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>

"
" Clam settings
"

nnoremap ! :Clam<space>
vnoremap ! :ClamVisual<space>

"
" Reassign arrow keys for line movement
"

nmap <Up> [e
vmap <Up> [egv
nmap <Down> ]e
vmap <Down> ]egv
nmap <Left> <<
vmap <Left> <gv
nmap <Right> >>
vmap <Right> >gv

"
" LanguageTool
"

let g:languagetool_jar='/Applications/LanguageTool-2.6/languagetool-commandline.jar'

"
" Set abnormal filetypes
"

" TODO remove once polyglot supports this
au! BufNewFile,BufRead *.plt,*.gnuplot setf gnuplot

"
" Prevent vim from writing newlines.
"

" :set wrap
" :set linebreak
" :set nolist  " list disables linebreak
" :set textwidth=0
" :set wrapmargin=0

"
" Easily open files with edit.
"	NOTE: http://vimcasts.org/episodes/the-edit-command/
"

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

"
" HTML5 indentation
"

let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"
let g:html_indent_inctags = "address,article,aside,audio,blockquote,canvas,dd,div,dl,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,header,hgroup,main,nav,noscript,ol,output,p,pre,section,table,tfoot,ul,video"

"
" Investigate
"

if exists(":investigate")
  let g:investigate_use_dash=1
endif

"
" Disable Ex mode -> Why? Never use it.
" http://www.bestofvim.com/tip/leave-ex-mode-good/
"

nnoremap Q <nop>

"
" Put output of shell command in a tmp buffer
" http://vim.wikia.com/wiki/Display_output_of_shell_commands_in_new_window
" https://svn.mageekbox.net/repositories/vim/trunk/.vimrc
"

function! s:ExecuteInShell(command, bang)
  let _ = a:bang != '' ? s:_ : a:command == '' ? '' : join(map(split(a:command), 'expand(v:val)'))

  if (_ != '')
    let s:_ = _
    let bufnr = bufnr('%')
    let winnr = bufwinnr('^' . _ . '$')
    silent! execute  winnr < 0 ? 'belowright new ' . fnameescape(_) : winnr .  'wincmd w'
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile wrap number
    silent! :%d
    let message = 'Execute ' . _ . '...'
    call append(0, message)
    echo message
    silent! 2d | resize 1 | redraw
    silent! execute 'silent! %!'. _
    silent! execute 'resize ' . line('$')
    silent! execute 'syntax on'
    silent! execute 'autocmd BufUnload <buffer> execute bufwinnr(' . bufnr . ') . ''wincmd w'''
    silent! execute 'autocmd BufEnter <buffer> execute ''resize '' .  line(''$'')'
    silent! execute 'nnoremap <silent> <buffer> <CR> :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>g :execute bufwinnr(' . bufnr . ') . ''wincmd w''<CR>'
    nnoremap <silent> <buffer> <C-W>_ :execute 'resize ' . line('$')<CR>
    silent! syntax on
  endif
endfunction

command! -complete=shellcmd -nargs=* -bang Shell call s:ExecuteInShell(<q-args>, '<bang>')
cabbrev shell Shell

