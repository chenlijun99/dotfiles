Plug 'itchyny/lightline.vim'

set laststatus=2

let g:lightline = {
			\ 'colorscheme': 'wombat',
			\ 'active': {
			\   'left': [ [ 'mode', 'paste' ],
			\             [ 'cocstatus', 'fugitive', 'filename', 'gutentags' ] ]
			\ },
			\ 'component_function': {
			\   'fugitive': 'LightlineFugitive',
			\   'readonly': 'LightlineReadonly',
			\   'modified': 'LightlineModified',
			\   'filename': 'LightlineFilename',
			\   'gutentags': 'gutentags#statusline',
			\   'language_server': 'LanguageClient#statusLine',
			\   'cocstatus': 'coc#status'
			\ },
			\ 'separator': { 'left': '|', 'right': '|' },
			\ 'subseparator': { 'left': '-', 'right': '-' }
			\ }

function! LightlineModified()
	if &filetype == "help"
		return ""
	elseif &modified
		return "+"
	elseif &modifiable
		return ""
	else
		return ""
	endif
endfunction

function! LightlineReadonly()
	if &filetype == "help"
		return ""
	elseif &readonly
		return "RO"
	else
		return ""
	endif
endfunction

function! LightlineFugitive()
	return exists('*fugitive#head') ? fugitive#head() : ''
endfunction

function! LightlineFilename()
	return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
				\ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
				\ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction
