" Long line handling - Plugin definition
" Handles both compressed and uncompressed files via BufReadPost.

if exists('g:loaded_clj_long_line')
    finish
endif
let g:loaded_clj_long_line = 1

augroup CljLongLine
    autocmd!
    " We experimented also with `BufReadCmd` to autoformat the content before
    " it is read into a buffer.
    " But doesn't play well with compressed files. E.g., *.json.xz.
    " We need to wait for the built-in gzip.vim plugin to decompress them
    " and then handle autoformatting in BufReadPost anyway.
    " And it turns out autoformatting BufReadPost is enough to avoid Vim
    " getting stuck
    autocmd BufReadPre * call clj#long_line#reset()
    autocmd BufReadPost * call clj#long_line#check_and_format()
augroup END
