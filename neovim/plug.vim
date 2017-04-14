
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
" Load UltiSnips and YouCompleteMe on insert mode
"
augroup load_us_ycm
  autocmd!
  autocmd InsertEnter * call plug#load('ultisnips', 'YouCompleteMe')
    \| autocmd! load_us_ycm
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
" Plug plugged
" NOTE: This is the directory that the plugins will be installed to.
"
call plug#begin('~/.config/nvim/plugged')

" Polyglot
" NOTE: Loading before to avoid overriding any file-specific plugins
Plug 'sheerun/vim-polyglot'

" Tabular
" NOTE: Must be loaded before Markdown
Plug 'godlygeek/tabular'

" Plug 'neovim/node-host', {
  " \'do': 'yarn'
" \}

" Plug 'airblade/vim-gitgutter'
" Plug 'edkolev/tmuxline.vim'
" Plug 'lifepillar/vim-solarized8'
" Plug 'tpope/vim-surround'
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
Plug 'ekalinin/Dockerfile.vim'
Plug 'ervandew/supertab'
Plug 'heavenshell/vim-jsdoc'
Plug 'iCyMind/NeoSolarized'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'kassio/neoterm'
Plug 'kshenoy/vim-signature'
Plug 'ktonga/vim-follow-my-lead'
Plug 'machakann/vim-sandwich'
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'metakirby5/codi.vim'
Plug 'moll/vim-node'
Plug 'mtth/scratch.vim'
Plug 'myusuf3/numbers.vim'
Plug 'neomake/neomake'
Plug 'ntpeters/vim-better-whitespace'
Plug 'othree/jspc.vim'
Plug 'pangloss/vim-javascript'
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
  Plug '~/.linuxbrew/opt/fzf'
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
Plug 'SirVer/ultisnips', {
  \'on': []
\}
  \| Plug 'chauncey-garrett/vim-snippets'

" YouCompleteMe
" NOTE: Must be loaded after supertab for it's completion to work
" NOTE: Must be loaded after UltiSnips for it's completion to work
Plug 'Valloric/YouCompleteMe', {
  \'on': [],
  \'do': function('BuildYouCompleteMe')
\}

" DevIcons
" NOTE: Must be loaded after NERDTree, vim-airline, CtrlP, powerline | unite, lightline.vim, vim-startify, vimfiler, flagship
Plug 'ryanoasis/vim-devicons'

call plug#end()

