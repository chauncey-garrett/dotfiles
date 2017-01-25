
"
" Plugged
"
source ~/.config/nvim/config/plug.vim

" Global.before
source ~/.config/nvim/config/_global.before.vim

" macOS settings
source ~/.config/nvim/config/_macos.vim

" Polyglot
" NOTE: Loading before to avoid overriding any file-specific plugins
source ~/.config/nvim/config/vim-polyglot.vim

" Disabled
" source ~/.config/nvim/config/ack.vim
" source ~/.config/nvim/config/ctrl-p.vim
" source ~/.config/nvim/config/surround.vim

source ~/.config/nvim/config/vim-expand-region.vim
source ~/.config/nvim/config/vim-sandwich.vim
source ~/.config/nvim/config/vim-visual-star-search.vim
source ~/.config/nvim/config/TaskList.vim
source ~/.config/nvim/config/indentLine.vim
source ~/.config/nvim/config/NeoSolarized.vim
source ~/.config/nvim/config/auto-pairs.vim
source ~/.config/nvim/config/committia.vim
source ~/.config/nvim/config/vim-speeddating.vim
source ~/.config/nvim/config/nvim-editcommand.vim
source ~/.config/nvim/config/taskpaper.vim
source ~/.config/nvim/config/supertab.vim
source ~/.config/nvim/config/spellcheck.vim
source ~/.config/nvim/config/csv.vim
source ~/.config/nvim/config/editorconfig.vim
source ~/.config/nvim/config/emmet.vim
source ~/.config/nvim/config/fzf.vim
source ~/.config/nvim/config/gundo.vim
source ~/.config/nvim/config/jekyll.vim
source ~/.config/nvim/config/jspc.vim
source ~/.config/nvim/config/neomake.vim
source ~/.config/nvim/config/neoterm.vim
source ~/.config/nvim/config/nerdcommenter.vim
source ~/.config/nvim/config/nerdtree.vim
source ~/.config/nvim/config/switch.vim
source ~/.config/nvim/config/tagbar.vim
source ~/.config/nvim/config/tern_for_vim.vim
source ~/.config/nvim/config/tmuxline.vim
source ~/.config/nvim/config/ultisnips.vim
source ~/.config/nvim/config/vim-abolish.vim
source ~/.config/nvim/config/vim-airline-themes.vim
source ~/.config/nvim/config/vim-airline.vim
source ~/.config/nvim/config/vim-applescript.vim
source ~/.config/nvim/config/vim-buffergator.vim
source ~/.config/nvim/config/vim-css-color.vim
source ~/.config/nvim/config/vim-easy-align.vim
source ~/.config/nvim/config/vim-fugitive.vim
source ~/.config/nvim/config/vim-gitgutter.vim
source ~/.config/nvim/config/vim-javascript.vim
source ~/.config/nvim/config/vim-signature.vim
source ~/.config/nvim/config/vim-snippets.vim
source ~/.config/nvim/config/vim-trailing-whitespace.vim
source ~/.config/nvim/config/vim-unimpaired.vim

source ~/.config/nvim/config/_tmp.vim

if (system('uname') =~ "darwin")
  source ~/.config/nvim/config/dash.vim
endif

" YouCompleteMe
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
" camelcasemotion
" characterize
" clam
" consolation
" criticmarkup
" cucumbertables
" dockerfile
" easytags
" funcoo
" gitv
" gnuplot
" investigate
" jade
" jdaddy
" jekyll
" language-tool
" marked
" misc
" numbers
" obsession
" plist
" preserve-no-eol
" remotecopy
" rhubarb
" search-complete
" space
" splitjoin
" syntax-nginx
" tabular
" tag-highlight
" tmux
" vimux
" wordy

"
" TODO.Janus
"

" LANGUAGES
"
" arduino
" clojure
" coffeescript
" cucumber
" elixir
" erlang
" git
" go
" haml
" haskell
" json
" less
" liquid
" markdown
" minitest
" mustache_handlebars
" nodejs
" puppet
" rails
" rdoc
" rspec
" ruby
" scala
" scss
" slim
" textile
" typescript

" PLUGINS
"
" before
" easymotion
" endwise TODO?
" eunuch
" gist
" indent-object
" janus
" kwbd
" multiple-cursors
" narrowregion
" repeat
" tlib
" vim-addon-mw-utils
" vimwiki
" vroom
" webapi
" zoomwin

" ├── ftdetect
" │   └── Dockerfile.vim
" ├── janus
" │   ├── ruby
" │   │   ├── janus
" │   │   │   ├── errors.rb
" │   │   │   ├── gems.rb
" │   │   │   ├── github.rb
" │   │   │   ├── plugins.rb
" │   │   │   └── vim.rb
" │   │   └── janus.rb
" │   ├── submodules.yaml
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
" │       │   ├── janus
" │       │   │   ├── after
" │       │   │   │   └── plugin
" │       │   │   │       └── vimrc_after.vim
" │       │   │   └── doc
" │       │   │       ├── janus.txt
" │       │   │       └── tags
" │       │   └── plugins.vim
" │       ├── gvimrc
" │       └── vimrc
" ├── Rakefile
" ├── README.md
" ├── snippets
" │   └── Dockerfile.snippets
" ├── syntax
" │   └── Dockerfile.vim
