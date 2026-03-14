function! clj#long_line#reset() abort
    if exists('b:clj_long_line_processed')
        " Reset so that when file is re-read (e.g., via :edit), 
        " auto formatting happens again.
        unlet b:clj_long_line_processed
    endif
endfunction

function! clj#long_line#check_and_format() abort
    " Check buffer content for long lines.
    
    " Skip if already formatted
    if get(b:, 'clj_long_line_processed', 0)
        return
    endif

    " If buffer is a binary, skip
    " E.g., the built-in gzip.vim does setlocal binary when opening compressed
    " files. After decompressing, it re-triggers the `BufReadPost` autocmd.
    if &binary
        return
    endif

    if ! s:is_buffer_long_line()
        return
    endif

    let l:ft = &filetype
    let l:formatter = s:get_formatter(l:ft)
    
    if !empty(l:formatter)
        echohl WarningMsg
        echom "Buffer contains a very long line. Automatically formatting..."
        echohl None
        
        call s:format_buffer(l:formatter)
    else
        " Long line detected but no formatter available
        let l:choice = confirm("Buffer contains very long lines but no formatter found for filetype '" . l:ft . "'. Open anyway?", "&Yes\n&No", 2)
        if l:choice != 1
            " Close the buffer if user declines
            bwipe!
        endif
    endif
endfunction

" --- Helpers ---

function! s:get_formatter(ft) abort
    " Determine formatter based on filetype
    " Returns command string (e.g. 'jq .') or empty
    
    if a:ft ==? 'json' || a:ft ==? 'jsonc'
        if executable('jq')
            return 'jq .'
        endif
    elseif a:ft ==? 'javascript' || a:ft ==? 'typescript'
        if executable('prettier')
            " Use current buffer name for prettier context if needed, or stdin
            return 'prettier --stdin-filepath ' . shellescape(expand('%'))
        endif
    endif
    
    return ''
endfunction

function! s:is_buffer_long_line() abort
    " Returns true if any line in buffer is longer than 500 chars (byte length)
    " Using search() to scan efficiently.
    " \%>500c matches if a line has a byte index > 500.
    
    let l:save_cursor = getcurpos()
    call cursor(1, 1)
    " c: accept match at cursor position
    " W: do not wrap around end of file
    " n: do not move cursor
    let l:found = search('\%>500c', 'cnW')
    call setpos('.', l:save_cursor)
    
    return l:found > 0
endfunction

function! s:format_buffer(formatter) abort
    try
        exe '%!' . a:formatter
        setlocal nomodified
        setlocal readonly
        let b:clj_long_line_processed = 1
    catch
        echohl ErrorMsg | echom "Formatting failed: " . v:exception | echohl None
    endtry
endfunction
