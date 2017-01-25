
"
" Taskpaper
"

" To change the default date format string used when marking a task complete, define the `task_paper_date_format` variable. The format matches your system's `strftime()` function. For example, to include the date and time in ISO8601 format:
let g:task_paper_date_format = "%Y-%m-%dT%H:%M:%S%z"

" To change the default archive project name, define the `task_paper_archive_project` variable.  The default value is "Archive".
let g:task_paper_archive_project = "Archive"

" By default, when you move a task, the cursor will follow that task to its new location.  To make the cursor stay in it's current location, change the `task_paper_follow_move` variable.
let g:task_paper_follow_move = 0

" If you want to hide done tasks when searching you can change the `task_paper_search_hide_done` variable.
let g:task_paper_search_hide_done = 1

" To set a custom style (colour, bold, etc.) for tags task_paper_styles variable, which is a dictionary.
let g:task_paper_styles={'wait': 'ctermfg=Blue guifg=Blue', 'FAIL': 'ctermbg=Red guibg=Red'}

" See |highlight-args| for a full description of the syntax.

