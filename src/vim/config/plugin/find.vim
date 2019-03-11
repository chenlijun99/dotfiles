let g:which_key_map.f = { 'name' : '+find' }

" junegunn/fzf {{{ 
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Files command with preview window
command! -bang -nargs=? -complete=dir Files
			\ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? GFiles
			\ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

function! FzfMainMapping()
	if exists('*fugitive#head') && !empty(fugitive#head())
		return ':FzfGFiles'
	else
		return ':Files'
	endif
endfunction

nnoremap <expr> <c-p> FzfMainMapping()

nnoremap <c-f> :FzfAg<cr>
let g:which_key_map.f.f = 'fuzzy files'
let g:which_key_map.f.t = 'fuzzy tags'
let g:which_key_map.f.c = 'fuzzy commits'
nnoremap <leader>ff :FzfFiles<cr>
nnoremap <leader>ft :FzfTags<cr>
nnoremap <leader>fc :FzfCommits<cr>

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
" }}} 

"mileszs/ack.vim {{{
Plug 'mileszs/ack.vim', { 'on' : ['Ack','LAck'] }

let g:which_key_map.f.a = 'ack/ag'
nnoremap <leader>fa :Ack!<Space>

if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif
let g:ack_use_dispatch = 1
"}}}

" set modeline
" vim: foldlevel=0 foldmethod=marker
