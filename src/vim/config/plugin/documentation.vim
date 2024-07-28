let g:which_key_map.k = { 'group_name' : '+documentation' }

" KabbAmine/zeavim.vim {{{
Plug 'KabbAmine/zeavim.vim', {'on': [
			\   'Zeavim', 'Docset',
			\   '<Plug>Zeavim',
			\   '<Plug>ZVVisSelection',
			\   '<Plug>ZVKeyDocset',
			\   '<Plug>ZVMotion'
			\ ]}

let g:which_key_map.k.k = 'Zeal'
nnoremap <leader>kk :Zeavim<cr>
let g:which_key_map.k.k = 'Zeal'
vnoremap <leader>kk :Zeavim<cr>
let g:which_key_map.k.K = 'Zeal search'
nnoremap <leader>kK :Zeavim!<cr>

let g:zv_disable_mapping = 1
let g:zv_file_types = {
			\ 'cpp'				: 'cpp,qt',
			\ 'sass'			: 'css,sass',
			\ 'scss'			: 'css,sass',
			\ 'cmake'			: 'cmake',
			\ '(plain|tex)?tex'	: 'latex',
			\ 'html'			: 'html,bootstrap',
			\ 'css'				: 'css',
			\ 'javascript'		: 'javascript,angularjs',
			\ 'sh'				: 'bash'
			\}

let g:zv_get_docset_by = ['ft', 'ext']
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker
