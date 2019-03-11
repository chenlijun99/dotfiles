"Plug 'ternjs/tern_for_vim' , { 'do' : 'npm install',
			"\'on' : [] }
"augroup load_tern
	"autocmd!
	"autocmd CursorHold *.js call plug#load('tern_for_vim')
				"\ | autocmd! load_tern
"augroup END
"let g:tern#arguments = ["--persistent"]
"let g:tern_show_signature_in_pum = 1
"let g:tern_show_argument_hints = 1

Plug 'jelera/vim-javascript-syntax' , { 'for' : 'javascript' }

Plug 'moll/vim-node' , { 'for' : 'javascript' }
