" Autocommands for large file handling

augroup CljLargeFile
    autocmd!
    " Check for large files on read
    autocmd BufReadPre * call clj#large_file#check_file()
    " Check for large buffers (e.g. after decompression)
    autocmd BufReadPost * call clj#large_file#check_buffer()
    " ftplugins may eanble some of the settings we disabled.
    " Re-disable them.
    autocmd FileType * call clj#large_file#apply_settings_if_applicable()
augroup END
