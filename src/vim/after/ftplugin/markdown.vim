setlocal spell spelllang=en,it,cjk
setlocal lazyredraw
setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
setlocal conceallevel=2
setlocal textwidth=80
setlocal formatoptions-=t

let g:which_key_map_local.p = 'Preview'
nnoremap <buffer> <localleader>p :MarkdownPreview<CR>

let g:which_key_map_local.t = 'Table of Contents'
nnoremap <buffer> <localleader>t :Vista toc<CR>
let g:which_key_map_local.T = 'Close Table of Contents'
nnoremap <buffer> <localleader>T :Vista!<CR>

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function Transform(markdownEscape) range
	if a:markdownEscape
		let l:scriptCall = s:path . '/md_to_anki.js --markdown-escape'
	else
		let l:scriptCall = s:path . '/md_to_anki.js'
	endif
	let @+ = system('echo ' . shellescape(s:get_visual_selection()) .' | ' . l:scriptCall)
endfunction

xnoremap Y :'<,'>call Transform(0)<cr>
xnoremap YY :'<,'>call Transform(1)<cr>
xnoremap <localleader>c c{{c1::<C-r>"}}<Esc>

" set modeline 
" vim: foldlevel=0 foldmethod=marker
