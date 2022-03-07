"
" HeaderDecrease and HeaderIncrease copied from plasticboy/vim-markdown
" I don't need the rest of the plugin (which is quite slow)
"
command! -buffer -range=% HeaderDecrease call s:HeaderDecrease(<line1>, <line2>)
command! -buffer -range=% HeaderIncrease call s:HeaderDecrease(<line1>, <line2>, 1)
let s:levelRegexpDict = {
    \ 1: '\v^(#[^#]@=|.+\n\=+$)',
    \ 2: '\v^(##[^#]@=|.+\n-+$)',
    \ 3: '\v^###[^#]@=',
    \ 4: '\v^####[^#]@=',
    \ 5: '\v^#####[^#]@=',
    \ 6: '\v^######[^#]@='
\ }
function! s:HeaderDecrease(line1, line2, ...)
	if a:0 > 0
		let l:increase = a:1
	else
		let l:increase = 0
	endif
	if l:increase
		let l:forbiddenLevel = 6
		let l:replaceLevels = [5, 1]
		let l:levelDelta = 1
	else
		let l:forbiddenLevel = 1
		let l:replaceLevels = [2, 6]
		let l:levelDelta = -1
	endif
	for l:line in range(a:line1, a:line2)
		if join(getline(l:line, l:line + 1), "\n") =~ s:levelRegexpDict[l:forbiddenLevel]
			echomsg 'There is an h' . l:forbiddenLevel . ' at line ' . l:line . '. Aborting.'
			return
		endif
	endfor
	let l:numSubstitutions = s:SetexToAtx(a:line1, a:line2)
	let l:flags = (&gdefault ? '' : 'g')
	for l:level in range(replaceLevels[0], replaceLevels[1], -l:levelDelta)
		execute 'silent! ' . a:line1 . ',' . (a:line2 - l:numSubstitutions) . 'substitute/' . s:levelRegexpDict[l:level] . '/' . repeat('#', l:level + l:levelDelta) . '/' . l:flags
	endfor
endfunction

" Convert Setex headers in range `line1 .. line2` to Atx.
"
" Return the number of conversions.
"
function! s:SetexToAtx(line1, line2)
    let l:originalNumLines = line('$')
    execute 'silent! ' . a:line1 . ',' . a:line2 . 'substitute/\v(.*\S.*)\n\=+$/# \1/'
    execute 'silent! ' . a:line1 . ',' . a:line2 . 'substitute/\v(.*\S.*)\n-+$/## \1/'
    return l:originalNumLines - line('$')
endfunction
