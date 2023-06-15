"
" Plug Functions
"

"
" Automatically install vim-plug and plugins on new systems
"
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
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
" Browse help files and README.md
" NOTE: Requires fzf.
" https://github.com/junegunn/vim-plug/wiki/extra#browse-help-files-and-readmemd
"
function! s:plug_help_sink(line)
  let dir = g:plugs[a:line].dir
  for pat in ['doc/*.txt', 'README.md']
    let match = get(split(globpath(dir, pat), "\n"), 0, '')
    if len(match)
      execute 'tabedit' match
      return
    endif
  endfor
  tabnew
  execute 'Explore' dir
endfunction

command! PlugHelp call fzf#run(fzf#wrap({
  \ 'source': sort(keys(g:plugs)),
  \ 'sink':   function('s:plug_help_sink')}))

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
    !python3 ./install.py --all
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
    \| exec 'source' '~/.dotfiles/neovim/config/' . a:repo . '.vim'
endfunction

"
" Plug all the things!
" NOTE: This is the directory that the plugins will be installed to.
"
call plug#begin('~/.config/nvim/plugged')

" NOTE: Loading first to avoid overriding any file-specific plugins
call Plugged('sheerun/vim-polyglot')

" NOTE: Must be loaded before plasticboy/vim-markdown
call Plugged('godlygeek/tabular')

" call Plugged('Yggdroot/indentLine') " TODO this causes a problem with vim-markdown
" call Plugged('chauncey-garrett/vim-plist') " TODO may not need this b/c of darfink/vim-plist; need to test on mac
" call Plugged('ervandew/supertab')
" call Plugged('go2null/Mark--Karkat')
" call Plugged('junegunn/vim-emoji') " TODO doesn't yet integrate with YouCompleteMe
" call Plugged('neomake/neomake')
" call Plugged('romainl/vim-qf')
" call Plugged('terryma/vim-multiple-cursors')
" call Plugged('tpope/vim-surround') " See machakann/vim-sandwich
call Plugged('AndrewRadev/splitjoin.vim')
call Plugged('AndrewRadev/switch.vim')
call Plugged('Chiel92/vim-autoformat')
call Plugged('Shougo/vinarise.vim')
call Plugged('airblade/vim-gitgutter')
call Plugged('andoriyu/salt-vim')
call Plugged('ap/vim-css-color')
call Plugged('aquasecurity/vim-trivy')
call Plugged('bkad/CamelCaseMotion')
call Plugged('brettanomyces/nvim-editcommand')
call Plugged('bronson/vim-visual-star-search')
call Plugged('chauncey-garrett/vim-applescript')
call Plugged('chauncey-garrett/vim-snippets')
call Plugged('chrisbra/unicode.vim')
call Plugged('christoomey/vim-sort-motion')
call Plugged('darfink/vim-plist')
call Plugged('davidoc/taskpaper.vim')
call Plugged('dbmrq/vim-redacted')
call Plugged('easymotion/vim-easymotion')
call Plugged('editorconfig/editorconfig-vim')
call Plugged('ekalinin/Dockerfile.vim')
call Plugged('elzr/vim-json')
call Plugged('fadein/vim-FIGlet')
call Plugged('google/vim-jsonnet')
call Plugged('hashivim/vim-consul')
call Plugged('hashivim/vim-packer')
call Plugged('hashivim/vim-terraform')
call Plugged('hashivim/vim-vagrant')
call Plugged('hashivim/vim-vaultproject')
call Plugged('heavenshell/vim-jsdoc')
call Plugged('itchyny/vim-cursorword')
call Plugged('jaxbot/semantic-highlight.vim')
call Plugged('jeetsukumaran/vim-buffergator')
call Plugged('jiangmiao/auto-pairs')
call Plugged('junegunn/vim-easy-align')
call Plugged('junegunn/vim-peekaboo')
call Plugged('kassio/neoterm')
call Plugged('kshenoy/vim-signature')
call Plugged('ktonga/vim-follow-my-lead')
call Plugged('lifepillar/vim-solarized8')
call Plugged('machakann/vim-sandwich')
call Plugged('majutsushi/tagbar')
call Plugged('martinda/Jenkinsfile-vim-syntax')
call Plugged('mattn/emmet-vim')
call Plugged('maxbrunsfeld/vim-yankstack')
call Plugged('metakirby5/codi.vim')
call Plugged('moll/vim-node')
call Plugged('moon-musick/vim-logrotate')
call Plugged('mtth/scratch.vim')
call Plugged('myusuf3/numbers.vim')
call Plugged('ntpeters/vim-better-whitespace')
call Plugged('othree/jspc.vim')
call Plugged('pangloss/vim-javascript')
call Plugged('parkr/vim-jekyll')
call Plugged('plasticboy/vim-markdown')
call Plugged('puremourning/vimspector')
call Plugged('reedes/vim-lexical')
call Plugged('reedes/vim-wordy')
call Plugged('rhysd/committia.vim')
call Plugged('roxma/vim-tmux-clipboard')
call Plugged('scrooloose/nerdcommenter')
call Plugged('sjl/gundo.vim')
call Plugged('speshak/vim-cfn')
call Plugged('tmux-plugins/vim-tmux')
call Plugged('towolf/vim-helm')
call Plugged('tpope/vim-abolish')
call Plugged('tpope/vim-dadbod')
call Plugged('tpope/vim-endwise')
call Plugged('tpope/vim-speeddating')
call Plugged('tpope/vim-unimpaired')
call Plugged('triglav/vim-visual-increment')
call Plugged('vim-scripts/TaskList.vim')
call Plugged('w0rp/ale')
call Plugged('wellle/tmux-complete.vim')
call Plugged('wincent/terminus')

" macOS
" TODO optimize check for system in global before file
if (system('uname') =~? 'darwin')
  call Plugged('rizzatti/dash.vim')
  call Plugged('itspriddle/vim-marked')

" Linux / Windows
else
  call Plugged('KabbAmine/zeavim.vim')
  Plug 'euclio/vim-markdown-composer', {
    \'do': function('BuildMarkdownComposer')
  \}
  source ~/.config/nvim/config/euclio/vim-markdown-composer.vim
endif

call Plugged('mattn/webapi-vim')
  \| call Plugged('mattn/gist-vim')

call Plugged('tpope/vim-fugitive')
  \| call Plugged('tpope/vim-rhubarb')
  \| call Plugged('tommcdo/vim-fubitive')
  \| call Plugged('shumphrey/fugitive-gitlab.vim')

call Plugged('xolox/vim-misc')
  \| call Plugged('xolox/vim-easytags')

call Plugged('terryma/vim-expand-region')
  \| call Plugged('michaeljsmith/vim-indent-object')

call Plugged('junegunn/goyo.vim')
  \| call Plugged('amix/vim-zenroom2')
  \| call Plugged('junegunn/limelight.vim')

" call Plugged('reedes/vim-thematic')
  " \| call Plugged('reedes/vim-pencil')
  " \| call Plugged('reedes/vim-colors-pencil')

Plug 'mhinz/vim-startify', {
  \'on': [
    \'Startify'
  \]
\}
source ~/.config/nvim/config/mhinz/vim-startify.vim

Plug 'pearofducks/ansible-vim', {
  \'do': 'brew install ansible && ./UltiSnips/generate.sh',
\}
source ~/.config/nvim/config/pearofducks/ansible-vim.vim

Plug 'vim-scripts/SpellCheck', {
  \'on': [
    \'SpellCheck'
  \]
\}
source ~/.config/nvim/config/vim-scripts/SpellCheck.vim

Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': [
    \ 'css',
    \ 'graphql',
    \ 'html',
    \ 'javascript',
    \ 'json',
    \ 'less',
    \ 'lua',
    \ 'markdown',
    \ 'php',
    \ 'python',
    \ 'ruby',
    \ 'scss',
    \ 'swift',
    \ 'typescript',
    \ 'vue'
  \]
\}
source ~/.config/nvim/config/prettier/vim-prettier.vim

"
" FZF
"
" On macOS, use homebrew's fzf
if (system('uname') =~? 'darwin')
  Plug '/usr/local/opt/fzf'
    \| Plug 'junegunn/fzf.vim', {
      \'do': 'brew install fzf bat delta ag rg perl',
    \}

" On linux, use linuxbrew's fzf
else
  Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
    \| Plug 'junegunn/fzf.vim', {
      \'do': 'brew install fzf bat git-delta ag rg perl',
    \}
endif
source ~/.config/nvim/config/junegunn/fzf.vim.vim

" Plug 'bigfish/vim-js-context-coloring', {
  " \'branch': 'neovim',
  " \'do': 'cd rplugin/node && yarn',
" \}

" Plug 'fatih/vim-go', {
  " \'do': ':GoInstallBinaries'
" \}
  " " \'tag': '*',
" source ~/.config/nvim/config/fatih/vim-go.vim

call Plugged('scrooloose/nerdtree')
  \| call Plugged('arkgast/nerdtree-execute') " TODO switch back to ivalkeen's version if it's ever updated
  " \| call Plugged('tiagofumo/vim-nerdtree-syntax-highlight')

Plug 'neoclide/coc.nvim', {
  \'branch': 'release',
  \'do': 'brew install hashicorp/tap/terraform-ls',
\}
source ~/.config/nvim/config/neoclide/coc.vim

Plug 'psliwka/vim-dirtytalk', {
  \'do': ':DirtytalkUpdate',
\}
source ~/.config/nvim/config/psliwka/vim-dirtytalk.vim

Plug 'chrisbra/csv.vim', {
  \'on': [
    \'CSVTable'
  \]
\}
source ~/.config/nvim/config/chrisbra/csv.vim

Plug 'marijnh/tern_for_vim', {
  \'do': 'yarn'
\}
source ~/.config/nvim/config/marijnh/tern_for_vim.vim

call Plugged('vim-airline/vim-airline')
  \| call Plugged('vim-airline/vim-airline-themes')

" UltiSnips
" NOTE: vim-snippets depends on UltiSnips
" Plug 'SirVer/ultisnips', {}
  " \| call Plugged('chauncey-garrett/vim-snippets')
" source ~/.config/nvim/config/SirVer/ultisnips.vim

" YouCompleteMe
" NOTE: Must be loaded after supertab for it's completion to work
" NOTE: Must be loaded after UltiSnips for it's completion to work
" Plug 'Valloric/YouCompleteMe', {
  " \'do': function('BuildYouCompleteMe')
" \}
" source ~/.config/nvim/config/Valloric/YouCompleteMe.vim

" DevIcons
" NOTE: Must be loaded after NERDTree, vim-airline, CtrlP, powerline, unite, lightline.vim, vim-startify, vimfiler, flagship
call Plugged('ryanoasis/vim-devicons')

call plug#end()

" Enable vim-surround keybindings
" https://github.com/machakann/vim-sandwich/wiki/Introduce-vim-surround-keymappings
" https://github.com/tpope/vim-surround
runtime macros/sandwich/keymap/surround.vim
