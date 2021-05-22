let g:which_key_map.k = { 'name' : '+documentation' }

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

" kkoomen/vim-doge {{{
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() }, 'on': ['DogeGenerate'] }
nnoremap <leader>kg :DogeGenerate<cr>
let g:which_key_map.k.g = 'Generate doc (doge)'
let g:doge_javascript_settings = {
\  'omit_redundant_param_types': 1,
\}
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker
