Plug 'w0rp/ale'
let g:ale_virtualtext_cursor = 1
let g:ale_completion_enabled = 0
let g:ale_lint_on_insert_leave = 1

autocmd! FileType c,cpp,java,rust,javascript,go,python let b:ale_enabled = 0
