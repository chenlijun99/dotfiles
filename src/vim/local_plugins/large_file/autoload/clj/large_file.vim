" Large file handling
"
" Sets b:clj_large_file = v:true if the file is large
" Disables heavy features for large files

function! clj#large_file#check_file() abort
    let l:f = expand('<afile>')
    if empty(l:f) || !filereadable(l:f)
        return
    endif
    
    let l:size = getfsize(l:f)
    
    " Ask for confirmation if file is extremely large (> 10MB)
    if l:size > 10 * 1024 * 1024
        let l:choice = confirm("File " . l:f . " is very large (" . (l:size / 1024 / 1024) . "MB). Open it?", "&Yes\n&No", 2)
        if l:choice != 1
            " Throw exception to abort the read
            throw "CljUserDeclinedBufRead"
        endif
    endif

    if l:size > 1024 * 1024
        let b:clj_large_file = v:true
        call s:disable_features()
        echohl WarningMsg
        echom "Large file detected (" . (l:size / 1024 / 1024) . "MB). Optimized mode enabled."
        echohl None
    endif
endfunction

function! clj#large_file#check_buffer() abort
    " Check buffer size (in bytes)
    " This handles cases where file on disk is small (compressed) but huge in memory
    let l:size = line2byte(line('$') + 1)
    if l:size > 1024 * 1024
        let b:clj_large_file = v:true
        call s:disable_features()
        echohl WarningMsg
        echom "Large buffer detected (" . (l:size / 1024 / 1024) . "MB). Optimized mode enabled."
        echohl None
    else
        call clj#large_file#apply_settings_if_applicable()
    endif
endfunction

function! clj#large_file#apply_settings_if_applicable() abort
    " If already detected as large file (e.g. from BufReadPre), enforce
    " settings again (e.g. because filetype detection might have re-enabled
    " syntax)
    if get(b:, 'clj_large_file', 0)
        call s:disable_features()
        return
    endif
endfunction

function! s:disable_features() abort
    setlocal foldmethod=manual
    setlocal nospell
    setlocal nowrap
    setlocal nolist
    setlocal norelativenumber
    setlocal nonumber
    setlocal nocursorline
    setlocal colorcolumn=
    setlocal foldcolumn=0
    setlocal noswapfile
    setlocal syntax=off
    
    if exists(":NoMatchParen")
        silent! NoMatchParen
    endif
endfunction
