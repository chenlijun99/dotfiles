" 'Konfekt/FastFold' {{{
" lazy fold recomputing
Plug 'Konfekt/FastFold'
" }}}

"bkad/CamelCaseMotion {{{
Plug 'bkad/CamelCaseMotion' , { 'on' : [] }

function! s:MapCamelCaseMotion()
	map <silent> w <Plug>CamelCaseMotion_w
	map <silent> b <Plug>CamelCaseMotion_b
	map <silent> e <Plug>CamelCaseMotion_e
	map <silent> ge <Plug>CamelCaseMotion_ge
	sunmap w
	sunmap b
	sunmap e
	sunmap ge
	omap <silent> iw <Plug>CamelCaseMotion_iw
	xmap <silent> iw <Plug>CamelCaseMotion_iw
	omap <silent> ib <Plug>CamelCaseMotion_ib
	xmap <silent> ib <Plug>CamelCaseMotion_ib
	omap <silent> ie <Plug>CamelCaseMotion_ie
	xmap <silent> ie <Plug>CamelCaseMotion_ie
endfunction

augroup load_camelcasemotion
	autocmd!
	autocmd FileType cpp,java,javascript,vim
				\ autocmd BufEnter * call plug#load('CamelCaseMotion')
				\ | call s:MapCamelCaseMotion()
				\ | autocmd! load_camelcasemotion
augroup END
"}}}

" junegunn/goyo.vim {{{
Plug 'junegunn/goyo.vim' , { 'on' : ['Goyo', 'Goyo!'] }
" }}}
" junegunn/rainbow_parentheses.vim {{{
Plug 'junegunn/rainbow_parentheses.vim'
" }}}
" junegunn/vim-easy-align {{{
Plug 'junegunn/vim-easy-align', { 'on' : ['EasyAlign'] }
" }}}

" jiangmiao/auto-pairs {{{
Plug 'jiangmiao/auto-pairs'
"}}}

" mhinz/vim-startify {{{
Plug 'mhinz/vim-startify'

" Let vim-rooter do its work
let g:startify_change_to_dir = 0
" }}}

"tpope/vim-dispatch {{{
Plug 'tpope/vim-dispatch', { 'on': ['Dispatch', 'Make', 'Start'] }
"}}}
" tpope/vim-repeat {{{
Plug 'tpope/vim-repeat'
" }}}
"tpope/vim-surround {{{
Plug 'tpope/vim-surround',
			\ { 'on': ['<Plug>Dsurround', '<Plug>Csurround', '<Plug>CSurround',
			\ '<Plug>Ysurround',  '<Plug>YSurround', '<Plug>Yssurround',
			\ '<Plug>YSsurround', '<Plug>VSurround', '<Plug>VgSurround'] }
xmap S <Plug>VSurround
"}}}
" tpope/vim-sleuth {{{
" Adjusts 'shiftwidth' and 'expandtab' heuristically based on the current file
Plug 'tpope/vim-sleuth'
"}}}

" mbbill/undotree {{{
Plug 'mbbill/undotree', { 'on': ['UndotreeToggle'] }
let g:which_key_map.u = 'Undotree'
nnoremap <leader>u :UndotreeToggle<CR>
" }}}

" rickhowe/diffchar.vim {{{
Plug 'rickhowe/diffchar.vim'
" }}}

" romainl/vim-cool {{{
Plug 'romainl/vim-cool'
" }}}

Plug 'powerman/vim-plugin-AnsiEsc' , { 'on' : ['AnsiEsc', 'AnsiEsc!'] }

" set modeline
" vim: foldlevel=0 foldmethod=marker
