call defx#custom#option('_', {
      \ 'winwidth': 32,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'show_ignored_files': 0,
      \ 'buffer_name': '',
      \ 'toggle': 0,
      \ 'resume': 1,
	  \ 'root_marker': ' ',
	  \ 'columns': 'indent:git:icons:filename:type',
      \ })

call defx#custom#column('git', {
	\   'indicators': {
	\     'Modified'  : '•',
	\     'Staged'    : '✚',
	\     'Untracked' : 'ᵁ',
	\     'Renamed'   : '≫',
	\     'Unmerged'  : '≠',
	\     'Ignored'   : 'ⁱ',
	\     'Deleted'   : '✖',
	\     'Unknown'   : '⁇'
	\   }
	\ })

call defx#custom#column('mark', { 'readonly_icon': '', 'selected_icon': '' })

" defx-icons plugin
let g:defx_icons_column_length = 2
let g:defx_icons_mark_icon = ''

call defx#custom#column('icon', {
			\ 'directory_icon': '▸',
			\ 'opened_icon': '▾',
			\ 'root_icon': ' ',
			\ })

autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
	" Define mappings
	nnoremap <silent><buffer><expr> <CR>
				\ defx#is_directory() ?
				\ defx#do_action('open_tree', 'toggle') : defx#do_action('drop')
	nnoremap <silent><buffer><expr> s
				\ defx#do_action('open', 'vsplit')
	nnoremap <silent><buffer><expr> o
				\ defx#is_directory() ?
				\ defx#do_action('open_tree', 'toggle') : defx#do_action('drop')
	nnoremap <silent><buffer><expr> x
				\ defx#do_action('close_tree')

	nnoremap <silent><buffer><expr> P
				\ defx#do_action('preview')
	nnoremap <silent><buffer><expr> yy
				\ defx#do_action('yank_path')
	nnoremap <silent><buffer><expr> I
				\ defx#do_action('toggle_ignored_files')
	nnoremap <silent><buffer><expr> ;
				\ defx#do_action('repeat')
	nnoremap <silent><buffer><expr> q
				\ defx#do_action('quit')

	nnoremap <silent><buffer><expr> ch
				\ defx#do_action('cd', ['..'])
	nnoremap <silent><buffer><expr> c~
				\ defx#do_action('cd')
	nnoremap <silent><buffer><expr> cd
				\ defx#do_action('change_vim_cwd')

	nnoremap <silent><buffer><expr> t
				\ defx#do_action('toggle_select')
	nnoremap <silent><buffer><expr> *
				\ defx#do_action('toggle_select_all')
	nnoremap <silent><buffer><expr> <C-l>
				\ defx#do_action('redraw')
	nnoremap <silent><buffer><expr> <C-g>
				\ defx#do_action('print')

	nnoremap <silent><buffer><expr> mc
				\ defx#do_action('copy')
	nnoremap <silent><buffer><expr> mm
				\ defx#do_action('move')
	nnoremap <silent><buffer><expr> mp
				\ defx#do_action('paste')
	nnoremap <silent><buffer><expr> mA
				\ defx#do_action('new_directory')
	nnoremap <silent><buffer><expr> ma
				\ defx#do_action('new_file')
	nnoremap <silent><buffer><expr> md
				\ defx#do_action('remove')
	nnoremap <silent><buffer><expr> mr
				\ defx#do_action('rename')
	nnoremap <silent><buffer><expr> mx
				\ defx#do_action('execute_system')
endfunction
