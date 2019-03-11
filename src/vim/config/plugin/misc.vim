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

" sheerun/vim-polyglot {{{
Plug 'sheerun/vim-polyglot'
" workaround to issue #162
" I don't want all js files to be treated as jsx files
let g:jsx_ext_required = 1

" Don't use LaTeX-Box. I'm already using vimtex plugin for LaTeX
let g:polyglot_disabled = ['latex']
" }}}

"'jiangmiao/auto-pairs' {{{
Plug 'jiangmiao/auto-pairs'
"}}}

"'KabbAmine/zeavim.vim' {{{
Plug 'KabbAmine/zeavim.vim', {'on': [
			\   'Zeavim', 'Docset',
			\   '<Plug>Zeavim',
			\   '<Plug>ZVVisSelection',
			\   '<Plug>ZVKeyDocset',
			\   '<Plug>ZVMotion'
			\ ]}

nnoremap K :Zeavim<cr>
vnoremap K :Zeavim<cr>
nnoremap <leader>K :Zeavim!<cr><cr>

let g:zv_disable_mapping = 1
let g:zv_file_types = {
			\ 'cpp'				:	'cpp,qt',
			\ 'cmake'			:	'cmake',
			\ '(plain|tex)?tex'	:	'latex',
			\ 'html'			:	'html,bootstrap',
			\ 'css'				:	'css',
			\ 'javascript'		:	'javascript,angularjs',
			\ 'sh'				:	'bash'
			\}

let g:zv_get_docset_by = ['ft', 'ext']
"}}}

" machakann/vim-highlightedyank {{{
Plug 'machakann/vim-highlightedyank'
if !exists('##TextYankPost')
	map y <Plug>(highlightedyank)
endif
hi def link HighlightedyankRegion PmenuSel
" }}}

" timakro/vim-searchant {{{
Plug 'timakro/vim-searchant'
hi def link SearchCurrent IncSearch
" }}}

" rhysd/clever-f.vim {{{
Plug 'rhysd/clever-f.vim'
let g:clever_f_across_no_line=1
" }}}

" mhinz/vim-startify {{{
Plug 'mhinz/vim-startify'
" }}}

"'easymotion/vim-easymotion' {{{
Plug 'easymotion/vim-easymotion' , { 'on' : '<Plug>(easymotion-prefix)' }

" m for move
map m <Plug>(easymotion-prefix)
map mm ms
"}}}

" Chiel92/vim-autoformat {{{
Plug 'Chiel92/vim-autoformat' , { 'on' : 'Autoformat' }
" }}}
"
" {{{ cs/alternate-file.vim
Plug 'cs/alternate-file.vim'
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
" tpope/vim-abolish {{{
Plug 'tpope/vim-abolish',
			\ { 'on': ['Abolish', 'Subvert'] }
" }}}

" set modeline
" vim: foldlevel=0 foldmethod=marker
