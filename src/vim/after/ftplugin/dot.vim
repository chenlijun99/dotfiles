let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
nnoremap <buffer> <silent> <leader>R :!dot -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rd :!dot -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rn :!neato -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rt :!twopi -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rc :!circo -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rf :!fdp -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
nnoremap <buffer> <silent> <leader>rs :!sfdp -Tsvg % -o %:r.svg<cr>:!eog %:r.svg &<cr>
