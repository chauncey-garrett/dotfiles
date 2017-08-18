set encoding=utf-8
scriptencoding utf-8

"
" NeoVim Plugged
"

" Install plugins
source ~/.config/nvim/plug.vim

" GUI settings
if has('gui_running')
  source ~/.config/nvim/config/_gui.vim
endif

" Global.before
source ~/.config/nvim/config/_global.before.vim

" macOS settings
if (system('uname') =~? 'darwin')
  source ~/.config/nvim/config/_macos.vim
endif

" Polyglot
" NOTE: Loading before to avoid overriding any file-specific plugins
" source ~/.config/nvim/config/vim-polyglot.vim

" source ~/.config/nvim/config/ack.vim
" source ~/.config/nvim/config/ctrl-p.vim
" source ~/.config/nvim/config/surround.vim
" source ~/.config/nvim/config/vim-nerdtree-syntax-highlight.vim
source ~/.config/nvim/config/vim-solarized8.vim
source ~/.config/nvim/config/CamelCaseMotion.vim
source ~/.config/nvim/config/Dockerfile.vim
source ~/.config/nvim/config/vim-sort-motion.vim
" source ~/.config/nvim/config/NeoSolarized.vim
source ~/.config/nvim/config/TaskList.vim
source ~/.config/nvim/config/ansible-vim.vim
source ~/.config/nvim/config/auto-pairs.vim
source ~/.config/nvim/config/colors-pencil.vim
source ~/.config/nvim/config/committia.vim
source ~/.config/nvim/config/csv.vim
source ~/.config/nvim/config/editorconfig.vim
source ~/.config/nvim/config/emmet.vim
source ~/.config/nvim/config/fzf.vim
source ~/.config/nvim/config/gundo.vim
source ~/.config/nvim/config/indentLine.vim
source ~/.config/nvim/config/jekyll.vim
source ~/.config/nvim/config/jspc.vim
source ~/.config/nvim/config/codi.vim
source ~/.config/nvim/config/scratch.vim
source ~/.config/nvim/config/lexical.vim
source ~/.config/nvim/config/neomake.vim
source ~/.config/nvim/config/neoterm.vim
source ~/.config/nvim/config/nerdcommenter.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/nvim-editcommand.vim
source ~/.config/nvim/config/pencil.vim
source ~/.config/nvim/config/spellcheck.vim
source ~/.config/nvim/config/splitjoin.vim
source ~/.config/nvim/config/supertab.vim
source ~/.config/nvim/config/switch.vim
source ~/.config/nvim/config/tabular.vim
source ~/.config/nvim/config/taskpaper.vim
source ~/.config/nvim/config/tern_for_vim.vim
source ~/.config/nvim/config/thematic.vim
source ~/.config/nvim/config/tmux-complete.vim
source ~/.config/nvim/config/ultisnips.vim
source ~/.config/nvim/config/vim-tmux-clipboard.vim
source ~/.config/nvim/config/unicode.vim
source ~/.config/nvim/config/vim-abolish.vim
source ~/.config/nvim/config/vim-airline-themes.vim
source ~/.config/nvim/config/vim-airline.vim
source ~/.config/nvim/config/vim-applescript.vim
source ~/.config/nvim/config/vim-autoformat.vim
source ~/.config/nvim/config/vim-better-whitespace.vim
source ~/.config/nvim/config/vim-buffergator.vim
source ~/.config/nvim/config/vim-css-color.vim
source ~/.config/nvim/config/vim-easy-align.vim
source ~/.config/nvim/config/vim-easymotion.vim
source ~/.config/nvim/config/vim-expand-region.vim
source ~/.config/nvim/config/vim-expand-region.vim
source ~/.config/nvim/config/vim-expand-region.vim
source ~/.config/nvim/config/vim-follow-my-lead.vim
source ~/.config/nvim/config/vim-indent-object.vim
source ~/.config/nvim/config/vim-jsdoc.vim
source ~/.config/nvim/config/vim-json.vim
source ~/.config/nvim/config/vim-jspc.vim
source ~/.config/nvim/config/vim-multiple-cursors.vim
source ~/.config/nvim/config/vim-node.vim
source ~/.config/nvim/config/vim-numbers.vim
source ~/.config/nvim/config/vim-qf.vim
source ~/.config/nvim/config/vim-sandwich.vim
source ~/.config/nvim/config/vim-signature.vim
source ~/.config/nvim/config/vim-snippets.vim
source ~/.config/nvim/config/vim-speeddating.vim
source ~/.config/nvim/config/vim-startify.vim
source ~/.config/nvim/config/vim-trailing-whitespace.vim
source ~/.config/nvim/config/vim-unimpaired.vim
source ~/.config/nvim/config/vim-visual-star-search.vim
source ~/.config/nvim/config/vim-yankstack.vim

source ~/.config/nvim/config/_tmp.vim

" macOS
if (system('uname') =~? 'darwin')
  source ~/.config/nvim/config/dash.vim
  source ~/.config/nvim/config/vim-marked.vim

" Linux / Windows
else
  source ~/.config/nvim/config/vim-markdown-composer.vim
endif

" EasyTags
" NOTE: EasyTags requires Misc
source ~/.config/nvim/config/vim-misc.vim
source ~/.config/nvim/config/vim-easytags.vim

" Markdown
" NOTE: Must be loaded after tabular
source ~/.config/nvim/config/vim-markdown.vim

" YouCompleteMe
" NOTE: Must be loaded after supertab for it's completion to work
" NOTE: Must be loaded after UltiSnips for it's completion to work
source ~/.config/nvim/config/YouCompleteMe.vim

" DevIcons
" NOTE: Must be loaded after NERDTree, vim-airline, CtrlP, powerline | unite, lightline.vim, vim-startify, vimfiler, flagship
source ~/.config/nvim/config/vim-devicons.vim

" Global.after
source ~/.config/nvim/config/_global.after.vim

"
" TODO.add.my.own.stuff
"
" characterize
" clam
" consolation
" criticmarkup
" cucumbertables
" funcoo
" gitv
" investigate
" jdaddy
" language-tool
" obsession
" plist
" preserve-no-eol
" remotecopy
" search-complete
" space
" syntax-nginx
" tag-highlight
" vimux
" wordy

"
" TODO.Janus
"

" LANGUAGES
"
" cucumber
" git
" liquid
" nodejs
" ruby
" scss
" typescript

" PLUGINS
"
" endwise TODO?
" eunuch
" gist
" kwbd
" narrowregion
" repeat
" tlib
" vim-addon-mw-utils
" vimwiki
" vroom
" webapi
" zoomwin

" ├── janus
" │   ├── ruby
" │   │   ├── janus
" │   │   │   ├── errors.rb
" │   │   │   ├── gems.rb
" │   │   │   ├── github.rb
" │   │   │   ├── plugins.rb
" │   │   │   └── vim.rb
" │   │   └── janus.rb
" │   └── vim
" │       ├── core
" │       │   ├── before
" │       │   │   └── plugin
" │       │   │       ├── autocmds.vim
" │       │   │       ├── filetypes.vim
" │       │   │       ├── gui_settings.vim
" │       │   │       ├── janus.vim
" │       │   │       ├── mappings.vim
" │       │   │       ├── settings.vim
" │       │   │       └── statusline.vim
" │       │   └── plugins.vim
" │       ├── gvimrc
" │       └── vimrc
" ├── Rakefile
" ├── README.md
