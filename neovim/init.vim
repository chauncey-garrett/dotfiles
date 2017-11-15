set encoding=utf-8
scriptencoding utf-8

"
" NeoVim Plugged
"

" Global.before
source ~/.config/nvim/config/_global.before.vim

" Install plugins
source ~/.config/nvim/plug.vim

" GUI settings
if has('gui_running')
  source ~/.config/nvim/config/_gui.vim
endif

" macOS settings
if (system('uname') =~? 'darwin')
  source ~/.config/nvim/config/_macos.vim
endif

" TODO organize
source ~/.config/nvim/config/_tmp.vim

" Global.after
source ~/.config/nvim/config/_global.after.vim

"
" TODO.add.my.own.stuff
"
" characterize
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
