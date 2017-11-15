
"
" lexical
"

" NOTE: Not needed for neovim
" set nocompatible

augroup lexical
  autocmd!
  autocmd FileType markdown,mkd,md call lexical#init()
  autocmd FileType textile call lexical#init()
  autocmd FileType text call lexical#init({ 'spell': 0 })
augroup END

" Default spelling language
let g:lexical#spelllang = ['en_us']

" Default spellfile
let g:lexical#spellfile = ['~/.vim/spell/en.utf-8.add',]

" Spelling suggestions in Normal mode
let g:lexical#spell_key = '<leader><leader>s'

" Default thesaurus
let g:lexical#thesaurus = ['~/.vim/thesaurus/mthesaur.txt',]

" Thesaurus suggestions in Normal mode
let g:lexical#thesaurus_key = '<leader><leader>t'

" Dictionary completion in Normal mode
let g:lexical#dictionary_key = '<leader><leader>d'
