
"
" Plug Functions
"

"
" Automatically install vim-plug and plugins on new systems
"
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

"
" Automatically install missing plugins on startup
" March 14, 2017
" https://github.com/junegunn/vim-plug/wiki/extra#automatically-install-missing-plugins-on-startup
"
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

"
" H to open help docs
" March 14, 2017
" https://github.com/junegunn/vim-plug/wiki/extra#h-to-open-help-docs
"
function! s:plug_doc()
  let l:name = matchstr(getline('.'), '^- \zs\S\+\ze:')
  if has_key(g:plugs, l:name)
    for l:doc in split(globpath(g:plugs[l:name].dir, 'doc/*.txt'), '\n')
      execute 'tabe' l:doc
    endfor
  endif
endfunction

augroup PlugHelp
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> H :call <sid>plug_doc()<cr>
augroup END

"
" gx to open GitHub URLs on browser
" March 14, 2017
" https://github.com/junegunn/vim-plug/wiki/extra#gx-to-open-github-urls-on-browser
"
function! s:plug_gx()
  let l:line = getline('.')
  let l:sha  = matchstr(l:line, '^  \X*\zs\x\{7,9}\ze ')
  let l:name = empty(l:sha) ? matchstr(l:line, '^[-x+] \zs[^:]\+\ze:')
                      \ : getline(search('^- .*:$', 'bn'))[2:-2]
  let l:uri  = get(get(g:plugs, l:name, {}), 'uri', '')
  if l:uri !~# 'github.com'
    return
  endif
  let l:repo = matchstr(l:uri, '[^:/]*/'.l:name)
  let l:url  = empty(l:sha) ? 'https://github.com/'.l:repo
                      \ : printf('https://github.com/%s/commit/%s', l:repo, l:sha)
  call netrw#BrowseX(l:url, 0)
endfunction

augroup PlugGx
  autocmd!
  autocmd FileType vim-plug nnoremap <buffer> <silent> gx :call <sid>plug_gx()<cr>
augroup END

"
" Extra key bindings for PlugDiff
" March 14, 2017
" https://github.com/junegunn/vim-plug/wiki/extra#extra-key-bindings-for-plugdiff
"   - J / K to scroll the preview window
"   - CTRL-N / CTRL-P to move between the commits
"   - CTRL-J / CTRL-K to move between the commits and synchronize the preview window
"
function! s:scroll_preview(down)
  silent! wincmd P
  if &previewwindow
    execute 'normal!' a:down ? "\<c-e>" : "\<c-y>"
    wincmd p
  endif
endfunction

function! s:setup_extra_keys()
  nnoremap <silent> <buffer> J :call <sid>scroll_preview(1)<cr>
  nnoremap <silent> <buffer> K :call <sid>scroll_preview(0)<cr>
  nnoremap <silent> <buffer> <c-n> :call search('^  \X*\zs\x')<cr>
  nnoremap <silent> <buffer> <c-p> :call search('^  \X*\zs\x', 'b')<cr>
  nmap <silent> <buffer> <c-j> <c-n>o
  nmap <silent> <buffer> <c-k> <c-p>o
endfunction

augroup PlugDiffExtra
  autocmd!
  autocmd FileType vim-plug call s:setup_extra_keys()
augroup END

"
" vimawesome.com completions for vim files
" https://gist.github.com/junegunn/5dff641d68d20ba309ce
"
function! VimAwesomeComplete() abort
  let l:prefix = matchstr(strpart(getline('.'), 0, col('.') - 1), '[.a-zA-Z0-9_/-]*$')
  echohl WarningMsg
  echo 'Downloading plugin list from VimAwesome'
  echohl None
ruby << EOF
  require 'json'
  require 'open-uri'

  query = VIM::evaluate('l:prefix').gsub('/', '%20')
  items = 1.upto(max_pages = 3).map do |page|
    Thread.new do
      url  = "http://vimawesome.com/api/plugins?page=#{page}&query=#{query}"
      data = open(url).read
      json = JSON.parse(data, symbolize_names: true)
      json[:plugins].map do |info|
        pair = info.values_at :github_owner, :github_repo_name
        next if pair.any? { |e| e.nil? || e.empty? }
        {word: pair.join('/'),
         menu: info[:category].to_s,
         info: info.values_at(:short_desc, :author).compact.join($/)}
      end.compact
    end
  end.each(&:join).map(&:value).inject(:+)
  VIM::command("let l:cands = #{JSON.dump items}")
EOF
" vint: -ProhibitUsingUndeclaredVariable
  if !empty(l:cands)
" vint: +ProhibitUsingUndeclaredVariable
    inoremap <buffer> <c-v> <c-n>
    augroup _VimAwesomeComplete
      autocmd!
      autocmd CursorMovedI,InsertLeave * iunmap <buffer> <c-v>
            \| autocmd! _VimAwesomeComplete
    augroup END

" vint: -ProhibitUsingUndeclaredVariable
    call complete(col('.') - strchars(l:prefix), l:cands)
" vint: +ProhibitUsingUndeclaredVariable
  endif
  return ''
endfunction

augroup VimAwesomeComplete
  autocmd!
  autocmd FileType vim inoremap <c-x><c-v> <c-r>=VimAwesomeComplete()<cr>
augroup END

"
" Setup YouCompleteMe
"
function! BuildYouCompleteMe(info)
  if a:info.status ==# 'installed' || a:info.force
    !./install.py --all
  endif
endfunction

"
" Setup Markdown Composer
"
function! BuildMarkdownComposer(info)
  if a:info.status !=# 'unchanged' || a:info.force
    !cargo build --release
  endif
endfunction

"
" Plugged
" Use Plug to source the plugin and then source the pluin's config file.
"
function! Plugged(repo)
  let l:repoName = substitute(a:repo, '^.*\/', '', 'g')

  Plug a:repo
    \| exec 'source' '~/.dotfiles/neovim/config/' . l:repoName . '.vim'
endfunction

"
" Plug plugged
" NOTE: This is the directory that the plugins will be installed to.
"
call plug#begin('~/.config/nvim/plugged')

" NOTE: Loading first to avoid overriding any file-specific plugins
call Plugged('sheerun/vim-polyglot')

" NOTE: Must be loaded before plasticboy/vim-markdown
call Plugged('godlygeek/tabular')

call Plugged('pangloss/vim-javascript')
" call Plugged('majutsushi/tagbar')

" Plug 'neovim/node-host', {
  " \'do': 'yarn'
" \}

" Plug 'airblade/vim-gitgutter'
" Plug 'tpope/vim-surround' " See machakann/vim-sandwich
Plug 'AndrewRadev/splitjoin.vim'
Plug 'AndrewRadev/switch.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'Yggdroot/indentLine'
Plug 'ap/vim-css-color'
Plug 'bkad/CamelCaseMotion'
Plug 'brettanomyces/nvim-editcommand'
Plug 'bronson/vim-visual-star-search'
Plug 'chauncey-garrett/vim-applescript'
Plug 'chauncey-garrett/vim-json'
Plug 'chrisbra/unicode.vim'
Plug 'christoomey/vim-sort-motion'
Plug 'davidoc/taskpaper.vim'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
" Plug 'go2null/Mark--Karkat'
Plug 'ekalinin/Dockerfile.vim'
Plug 'ervandew/supertab'
Plug 'heavenshell/vim-jsdoc'
" Plug 'iCyMind/NeoSolarized'
Plug 'lifepillar/vim-solarized8'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'kassio/neoterm'
Plug 'kshenoy/vim-signature'
Plug 'ktonga/vim-follow-my-lead'
Plug 'machakann/vim-sandwich'
Plug 'mattn/emmet-vim'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'metakirby5/codi.vim'
Plug 'moll/vim-node'
Plug 'mtth/scratch.vim'
Plug 'myusuf3/numbers.vim'
Plug 'neomake/neomake'
Plug 'ntpeters/vim-better-whitespace'
Plug 'othree/jspc.vim'
Plug 'pearofducks/ansible-vim'
Plug 'plasticboy/vim-markdown'
Plug 'reedes/vim-lexical'
Plug 'rhysd/committia.vim'
Plug 'romainl/vim-qf'
Plug 'roxma/vim-tmux-clipboard'
Plug 'scrooloose/nerdcommenter'
Plug 'sjl/gundo.vim'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmux-plugins/vim-tmux'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/TaskList.vim'
Plug 'wellle/tmux-complete.vim'

" macOS
" TODO optimize check for system in global before file
if (system('uname') =~? 'darwin')
  Plug 'rizzatti/dash.vim'
  Plug 'chauncey-garrett/vim-marked'

" Linux / Windows
else
  Plug 'euclio/vim-markdown-composer', {
    \'do': function('BuildMarkdownComposer')
  \}
endif

Plug 'xolox/vim-misc'
    \| Plug 'xolox/vim-easytags'

Plug 'terryma/vim-expand-region'
    \| Plug 'michaeljsmith/vim-indent-object'

Plug 'junegunn/goyo.vim'
    \| Plug 'amix/vim-zenroom2'
    \| Plug 'junegunn/limelight.vim'

Plug 'reedes/vim-thematic'
    \| Plug 'reedes/vim-pencil'
    \| Plug 'reedes/vim-colors-pencil'

Plug 'mhinz/vim-startify', {
  \'on': [
    \'Startify'
  \]
\}

Plug 'vim-scripts/SpellCheck', {
  \'on': [
    \'SpellCheck'
  \]
\}

"
" FZF
"
" On macOS, use homebrew's fzf
if (system('uname') =~? 'darwin')
  Plug '/usr/local/opt/fzf'
    \| Plug 'junegunn/fzf.vim'

" On linux, use linuxbrew's fzf
else
  Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
    \| Plug 'junegunn/fzf.vim'
endif

Plug 'vim-airline/vim-airline'
  \| Plug 'vim-airline/vim-airline-themes'

" Plug 'bigfish/vim-js-context-coloring', {
  " \'branch': 'neovim',
  " \'do': 'cd rplugin/node && yarn',
" \}

Plug 'scrooloose/nerdtree'
    " \| Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

Plug 'chrisbra/csv.vim', {
  \'on': [
    \'CSVTable'
  \]
\}

Plug 'marijnh/tern_for_vim', {
  \'do': 'yarn'
\}

" UltiSnips
" NOTE: vim-snippets depends on UltiSnips
Plug 'SirVer/ultisnips', {}
  \| Plug 'chauncey-garrett/vim-snippets'

" YouCompleteMe
" NOTE: Must be loaded after supertab for it's completion to work
" NOTE: Must be loaded after UltiSnips for it's completion to work
Plug 'Valloric/YouCompleteMe', {
  \'do': function('BuildYouCompleteMe')
\}

" DevIcons
" NOTE: Must be loaded after NERDTree, vim-airline, CtrlP, powerline | unite, lightline.vim, vim-startify, vimfiler, flagship
Plug 'ryanoasis/vim-devicons'

call plug#end()

