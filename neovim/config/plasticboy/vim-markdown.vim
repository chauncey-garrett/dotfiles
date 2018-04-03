
"
" Markdown
"

" NOTE: if links, bold/italic text, etc. are not properly concealed, then some
" other plugin is likely messing with the conceallevel. A link should be
" concealed unless you are in insert mode or the cursor is over it.
set conceallevel=2

" Disable conceal characters
" let g:vim_markdown_conceal = 0

" Highlight LaTeX math
let g:vim_markdown_math = 1

" Highlight YAML front matter as used by Jekyll or Hugo.
let g:vim_markdown_frontmatter = 1

" Highlight JSON front matter as used by Hugo.
let g:vim_markdown_json_frontmatter = 1

" Highlight TOML front matter as used by Hugo.
let g:vim_markdown_toml_frontmatter = 1

