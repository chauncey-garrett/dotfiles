
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
  if a:info.status == 'installed' || a:info.force
    !./install.sh --all
  endif
endfunction

"
" Setup Tern
"
function! BuildTern(info)
  if a:info.status == 'installed' || a:info.force
    !npm install
  endif
endfunction

"
" Plug plugged
"

call plug#begin('~/.config/nvim/plugged')

" Plug 'tpope/vim-surround'

Plug 'vim-scripts/TaskList.vim'
Plug 'bronson/vim-visual-star-search'
Plug 'terryma/vim-expand-region'
Plug 'cmachakann/vim-sandwich'
Plug 'tpope/vim-speeddating'
Plug 'Yggdroot/indentLine'
Plug 'AndrewRadev/switch.vim'
Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-css-color'
Plug 'brettanomyces/nvim-editcommand'
Plug 'bronson/vim-trailing-whitespace'
Plug 'chauncey-garrett/vim-applescript'
Plug 'editorconfig/editorconfig-vim'
Plug 'edkolev/tmuxline.vim'
Plug 'ervandew/supertab'
Plug 'iCyMind/NeoSolarized'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'kassio/neoterm'
Plug 'kshenoy/vim-signature'
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim'
Plug 'neomake/neomake'
Plug 'rhysd/committia.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'sheerun/vim-polyglot'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'

if (system('uname') =~ "darwin")
  Plug 'rizzatti/dash.vim'
endif

Plug 'vim-scripts/SpellCheck', {
  \'on': [
    \'SpellCheck'
  \]
\}

"
" FZF
"
" On macOS, use homebrew's fzf
if (system('uname') =~ "darwin")
  Plug '/usr/local/opt/fzf'
    \| Plug 'junegunn/fzf.vim'

" On linux, use linuxbrew's fzf
else
  Plug '~/.linuxbrew/opt/fzf'
    \| Plug 'junegunn/fzf.vim'
endif

"
" Airline
"
Plug 'vim-airline/vim-airline'
  \| Plug 'vim-airline/vim-airline-themes'

Plug 'othree/jspc.vim', {
  \'for': [
    \'coffeescript',
    \'livescript',
    \'javascript',
    \'javascript.jsx',
    \'typescript'
  \]
\}

Plug 'davidoc/taskpaper.vim', {
  \'for': [
    \'taskpaper'
  \]
\}

Plug 'scrooloose/nerdtree', {
  \'on': [
    \'NERDTreeToggle',
    \'NERDTreeFind'
  \]
\}

Plug 'jeetsukumaran/vim-buffergator'
" Plug 'jeetsukumaran/vim-buffergator', {
  " \'on': [
    " \'BuffergatorToggle'
  " \]
" \}

Plug 'chrisbra/csv.vim', {
  \'on': [
    \'CSVTable'
  \],
  \'for': [
    \'csv'
  \]
\}

Plug 'marijnh/tern_for_vim', {
  \'do': function('BuildTern'),
  \'for': [
    \'javascript',
    \'javascript.jsx'
  \]
\}

"
" UltiSnips
" NOTE: vim-snippets depends on UltiSnips
"
Plug 'SirVer/ultisnips', {
  \'on': []
\}
  \| Plug 'chauncey-garrett/vim-snippets'

"
" YouCompleteMe
"
Plug 'Valloric/YouCompleteMe', {
  \'on': [],
  \'do': function('BuildYouCompleteMe')
\}

"
" Order matters:
"

"
" DevIcons
" NOTE: Must be loaded after NERDTree, vim-airline, CtrlP, powerline | unite, lightline.vim, vim-startify, vimfiler, flagship
"
Plug 'ryanoasis/vim-devicons'

call plug#end()

