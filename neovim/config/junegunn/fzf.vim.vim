"
" fzf
" https://github.com/junegunn/fzf.vim
" https://www.reddit.com/r/neovim/comments/3oeko4/post_your_fzfvim_configurations/cvxev6j/
"

" Search files (in context of Neovim's path)
nnoremap <C-P> :Files<CR>

" Search Most Recently Used (MRU) files
nnoremap <C-h> :History<CR>

" Search open buffer list
nnoremap <C-b> :Buffers<CR>

" Search file contents
nnoremap <C-f> :Rg<CR>

" Search lines in the current buffer
nnoremap <M-f> :BLines<CR>

" Search search (/) history
nnoremap <M-/> :History/<CR>

" Search command (:) history
nnoremap <M-;> :History:<CR>

" Search Marks
nnoremap <M-m> :Marks<CR>

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
\}

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

" Rg only matches file contents
" https://github.com/junegunn/fzf.vim/issues/714#issuecomment-428802659
command! -bang -nargs=* Rg
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
