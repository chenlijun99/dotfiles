if executable('eclimd')  
	if ! eclim#EclimAvailable()
		Start! eclimd
	endif
	setlocal omnifunc=eclim#java#complete#CodeComplete
else
	call plug#load('vim-javacomplete2')
	setlocal omnifunc=javacomplete#Complete
endif

nnoremap <buffer> <leader>r :call Run()<cr>

" {{{ functions and commands
command! -nargs=* Run call Run(<f-args>)

function! Run(...)
	let mainFile = JavaMain()
	if empty(mainFile)
		return
	endif
	let mainExecutable = substitute(mainFile, "\.java$", "", "")
	
	let runArgs = ''
	for a in a:000
		let runArgs .= a . ' '
	endfor
	execute 'Start javac ' . expand('%') . ' && javac ' . mainFile . ' && ' . 'java ' . mainExecutable . ' ' . runArgs
endfunction

" get java mains
function! JavaMain()
	" plural of main -> mains
	let mains = taglist('main')

	if len(mains) == 0
		echo "Main method not found"
		return

	elseif len(mains) == 1
		return mains['filename']

	elseif len(mains) > 1
		let message = ""
		let index = 0
		for main in mains
			let message .= "(" . index . ") " . main['filename'] . "\n"
			let index += 1
		endfor
		echo message

		let userinput = input("\nSelect one candidate: ", '')
		if empty(userinput)
			return ''
		elseif userinput >=0 && userinput < len(mains)
			return mains[userinput]['filename']
		else
			echoerr "Invalid selections"
		endif
	endif
endfunction
" }}}

" set modeline 
" vim: foldlevel=0 foldmethod=marker
