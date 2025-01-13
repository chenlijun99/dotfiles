if clj#core#enable_full_power()
	" fzf.vim is used only as fallback
	finish
endif
function! s:ignore_submodules(...)
	if a:0 > 0
		let prepend = a:1
	else
		let prepend = ''
	endif
	if a:0 > 1
		let append = a:2
	else
		let append = ''
	endif
	if a:0 > 2
		let separator = a:3
	else
		let separator = ' '
	endif
	let submodules = system("git submodule | awk '{print $2}'")
	let submodules = split(submodules, '\n')
	let ignore_args = ''
	for submodule in submodules
		let ignore_args .= prepend . submodule . append . separator
	endfor
	return ignore_args
endfunction

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

function! s:get_fzf_main_mapping()
	if exists('*FugitiveHead') && !empty(FugitiveHead())
		return ':FzfGFiles'
	else
		return ':FzfFiles'
	endif
endfunction

if executable('rg')
	function! s:custom_find()
		call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case "
					\.s:ignore_submodules("-g '!", "'").shellescape(''), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), 0)
	endfunction
	let g:which_key_map.f.f = 'fuzzy find'
	nnoremap <silent> <leader>ff :FzfRg<cr>
elseif executable('ag')
	function! s:custom_find()
		call fzf#vim#grep("ag --nogroup --column --color "
					\.s:ignore_submodules("--ignore '", "'").shellescape('^(?=.)'), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), 0)
	endfunction
	let g:which_key_map.f.f = 'fuzzy find'
	nnoremap <silent> <leader>ff :FzfAg<cr>
endif

nnoremap <expr> <c-p> <SID>get_fzf_main_mapping()
nnoremap <silent> <c-f> :call <SID>custom_find()<cr>

nnoremap <silent> <c-b> :FzfBuffers<cr>
let g:which_key_map.f.P = 'fuzzy files'
nnoremap <silent> <leader>fP :FzfFiles<cr>
let g:which_key_map.f.p = 'fuzzy git (+submodules)'
nnoremap <silent> <leader>fp :FzfGFiles --recurse-submodules<cr>
let g:which_key_map.f.t = 'fuzzy tags'
nnoremap <silent> <leader>ft :FzfTags<cr>
let g:which_key_map.f.c = 'fuzzy commits'
nnoremap <silent> <leader>fc :FzfCommits<cr>

" Use fzf to complete paths. Very convenient.
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

let g:fzf_command_prefix = 'Fzf'

" Default fzf layout
" - down / up / left / right
let g:fzf_layout = { 'down': '37%' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
			\ { 'fg':      ['fg', 'Normal'],
			\ 'bg':      ['bg', 'Normal'],
			\ 'hl':      ['fg', 'Comment'],
			\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
			\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
			\ 'hl+':     ['fg', 'Statement'],
			\ 'info':    ['fg', 'PreProc'],
			\ 'prompt':  ['fg', 'Conditional'],
			\ 'pointer': ['fg', 'Exception'],
			\ 'marker':  ['fg', 'Keyword'],
			\ 'spinner': ['fg', 'Label'],
			\ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'
let g:fzf_preview_window = ['hidden,right,50%', 'ctrl-_']
