" NOTE: localvimrc plugin has to stay above all the other plugins
" this way we can be sure that variables set in .lvimrc are
" effectively applied
" embear/vim-localvimrc {{{
Plug 'embear/vim-localvimrc'
let g:localvimrc_ask=0
" }}}

" junegunn/fzf.vim {{{
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Files command with preview window
command! -bang -nargs=? -complete=dir Files
			\ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? GFiles
			\ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

let g:fzf_launcher = 'xterm -fa "Monospace" -fs 12 -e bash -ic %s'
autocmd! BufEnter * call SetFzfMainMapping()
nnoremap <expr> <c-p> FzfMainMapping()

function! FzfMainMapping()
	if exists('*fugitive#head') && !empty(fugitive#head())
		return ':FzfGFiles'
	else
		return ':Files'
	endif
endfunction

nnoremap <c-f> :FzfAg<cr>
nnoremap <leader>pf :FzfFiles<cr>
nnoremap <leader>pt :FzfTags<cr>
nnoremap <leader>ph :FzfHistory<cr>
nnoremap <leader>pbc :FzfBCommits<cr>
nnoremap <leader>pc :FzfCommits<cr>
nnoremap <leader>pp :Fzf

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
" junegunn/goyo.vim {{{
Plug 'junegunn/goyo.vim' , { 'on' : ['Goyo', 'Goyo!'] }
" }}}
" junegunn/vim-slash {{{
Plug 'junegunn/vim-slash'
" }}}
" junegunn/rainbow_parentheses.vim {{{
Plug 'junegunn/rainbow_parentheses.vim'
" }}}
" junegunn/vim-easy-align {{{
Plug 'junegunn/vim-easy-align', { 'on' : ['EasyAlign'] }
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

" christoomey/vim-conflicted {{{
Plug 'christoomey/vim-conflicted', { 'on': ['Conflicted','GitNextConflict']}
let g:diffget_local_map = '<leader>gl'
let g:diffget_upstream_map = '<leader>gu'
" }}}

" tpope/vim-eunuch {{{
Plug 'tpope/vim-eunuch'
" }}}

" sheerun/vim-polyglot {{{
Plug 'sheerun/vim-polyglot'
" workaround to issue #162
" I don't want all js files to be treated as jsx files
let g:jsx_ext_required = 1
" Don't use LaTeX-Box. I'm already using vimtex plugin for LaTeX
let g:polyglot_disabled = ['latex']
" }}}

" Sidepanel {{{

" 'majutsushi/tagbar' {{{
Plug 'majutsushi/tagbar', { 'on' :
			\['TagbarToggle',
			\'SidePanel tagbar',
			\'TagbarOpen',
			\'TagbarClose']}
let g:tagbar_left=0
let g:tagbar_width=20
" }}}

" 'scrooloose/nerdtree' {{{
Plug 'scrooloose/nerdtree' , { 'on' :
			\['NERDTree',
			\'NERDTreeToggle',
			\'SidePanel nerdtree',
			\'NERDTreeFind',
			\'NERDTreeClose'] }
let g:NERDTreeWinSize=30

"xuyuanp/nerdtree-git-plugin {{{
Plug 'xuyuanp/nerdtree-git-plugin' , { 'on' :
			\['NERDTree',
			\'NERDTreeToggle',
			\'SidePanel nerdtree',
			\'NERDTreeFind',
			\'NERDTreeClose'] }
"}}}
" }}}

" mbbill/undotree {{{
Plug 'mbbill/undotree' , { 'on' : [
			\'UndotreeToggle',
			\'UndotreeShow',
			\] 
			\}
" }}}

nnoremap so :TagbarToggle<cr>
nnoremap sf :NERDTreeFind<cr>
nnoremap su :UndotreeToggle<cr>
nnoremap S :TagbarClose<cr>:NERDTreeClose<cr>:UndotreeHide<cr>
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

" airblade/vim-gitgutter {{{
Plug 'airblade/vim-gitgutter'
" }}}

" 'ervandew/supertab' {{{
"Plug 'ervandew/supertab' , { 'on' : [] }
"let g:SuperTabDefaultCompletionType = "<c-n>"
"augroup load_supertab
"autocmd!
"autocmd InsertEnter * call plug#load('supertab')
"\ | autocmd! load_supertab
"augroup END
" }}}

" 'scrooloose/nerdcommenter' {{{
Plug 'scrooloose/nerdcommenter' , { 'on' : '<Plug>NERDCommenterToggle' }
nmap <leader>c<space> <Plug>NERDCommenterToggle
vmap <leader>c<space> <Plug>NERDCommenterToggle
"}}}

" 'bling/vim-bufferline' {{{
Plug 'bling/vim-bufferline'
let g:bufferline_echo = 1
let g:bufferline_active_buffer_left = '['
" }}}

" 'Valloric/ListToggle' {{{
Plug 'Valloric/ListToggle'
" set location list height
let g:lt_height=10
let g:lt_location_list_toggle_map = '<leader>l'
let g:lt_quickfix_list_toggle_map = '<leader>q'

nmap <Plug>JumpNextLocationList :lnext<Bar>
			\ silent! call repeat#set("\<Plug>JumpNextLocationList")<cr>
nmap <c-j> <Plug>JumpNextLocationList
nmap <Plug>JumpPreviousLocationList :lprevious<Bar>
			\ silent! call repeat#set("\<Plug>JumpPreviousLocationList")<cr>
nmap <c-k> <Plug>JumpPreviousLocationList

nmap <Plug>JumpNextQuickFix :cnext<Bar>
			\ silent! call repeat#set("\<Plug>JumpNextQuickFix")<cr>
nmap <leader>j <Plug>JumpNextQuickFix
nmap <Plug>JumpPreviousQuickFix :cprevious<Bar>
			\ silent! call repeat#set("\<Plug>JumpPreviousQuickFix")<cr>
nmap <leader>k <Plug>JumpPreviousQuickFix
"}}}

" istib/vifm.vim {{{
Plug 'istib/vifm.vim' , { 'on' : 'EditVifm' }
nnoremap <leader>o :EditVifm<cr>
" }}}

" 'terryma/vim-multiple-cursors' {{{
Plug 'terryma/vim-multiple-cursors' , { 'on' : 'MultipleCursorsFind' }
" }}}

" 'romgrk/winteract.vim' {{{

" add window mode to vim
Plug 'romgrk/winteract.vim' , { 'on' : 'InteractiveWindow' }
nnoremap <c-w> :InteractiveWindow<cr>
function! SetupWinteract()
	let g:winmap.normal = {
				\ "\<c-h>": "normal! \<C-w><" , "=": "normal! \<C-w>=" ,
				\ "\<c-j>": "normal! \<C-w>-" , "f": "normal! \<C-w>_" ,
				\ "\<c-k>": "normal! \<C-w>+" , "F": "normal! \<C-w>|" ,
				\ "\<c-l>": "normal! \<C-w>>" , "o": "normal! \<C-w>o" ,
				\
				\ "|": "exe g:winmode.count.'wincmd |'",
				\ "\\": "exe g:winmode.count.'wincmd _'",
				\ "&": "normal! :\<C-r>=&tw\<CR>wincmd |\<CR>" ,
				\
				\ "h": "normal! \<C-w>h" ,  "H": "normal! \<C-w>H" ,
				\ "j": "normal! \<C-w>j" ,  "J": "normal! \<C-w>J" ,
				\ "k": "normal! \<C-w>k" ,  "K": "normal! \<C-w>K" ,
				\ "l": "normal! \<C-w>l" ,  "L": "normal! \<C-w>L" ,
				\
				\ "x": "normal! \<C-w>c" , "n": "normal! :bn\<CR>" ,
				\ "c": "normal! \<C-w>c" , "p": "normal! :bp\<CR>" ,
				\ "s": "normal! \<C-w>s" , "\<TAB>": "normal! :bn\<CR>" ,
				\ "v": "normal! \<C-w>v" , "\<S-TAB>": "normal! :bp\<CR>" ,
				\
				\ "w": "normal! \<C-w>w" , "\<A-w>": "normal! \<C-w>p" ,
				\ "W": "normal! \<C-w>W" ,
				\ "q": "normal! :copen\<CR>" ,
				\
				\ "m": "let g:winmode.submode='move'" ,
				\ ":": "let g:winmode.submode='set'" ,
				\ "t": "let g:winmode.submode='tab'" ,
				\
				\ "d": "bdelete" ,
				\ ";": "terminal" ,
				\
				\ "\<ESC>": "let exitwin=1" ,
				\ "\<CR>": "let exitwin=1" ,
				\}

	let g:winmap.move = {
				\ "h": "normal! \<C-w>H" ,
				\ "j": "normal! \<C-w>J" ,
				\ "k": "normal! \<C-w>K" ,
				\ "l": "normal! \<C-w>L" ,
				\ "x": "normal! \<C-w>x" ,
				\ "r": "normal! \<C-w>r" ,
				\ "\<ESC>": "\" NOP" ,
				\ }

	let g:winmap.set = {
				\ "w": "exe g:winmode.count.'wincmd |'",
				\ "h": "exe g:winmode.count.'wincmd _'",
				\ "W": "wincmd |",
				\ "H": "wincmd _",
				\ "\<ESC>": "let resetmode=1" ,
				\ }

	let g:winmap.tab = {
				\ "o": "tab sview %" ,
				\ "e": "tabnew" ,
				\ "x": "tabclose" ,
				\ "n": "tabnext" ,
				\ "p": "tabprevious" ,
				\
				\ "w": "let g:winmode.submode='normal'" ,
				\ "\<ESC>": "let exitwin=1" ,
				\ }
endfunction
autocmd! User winteract.vim call SetupWinteract()
"}}}

" 'Konfekt/FastFold' {{{
" lazy fold recomputing
Plug 'Konfekt/FastFold'
" }}}

"'jiangmiao/auto-pairs' {{{
Plug 'jiangmiao/auto-pairs' , { 'on' : [] }
augroup load_auto-pairs
	autocmd!
	autocmd InsertEnter * call plug#load('auto-pairs')
				\ | autocmd! load_auto-pairs
augroup END
autocmd! User auto-pairs call AutoPairsInit()
"}}}

"'easymotion/vim-easymotion' {{{
Plug 'easymotion/vim-easymotion' , { 'on' : '<Plug>(easymotion-prefix)' }

" m for move
map m <Plug>(easymotion-prefix)
map mm ms
"}}}

" 'airblade/vim-rooter' {{{
Plug 'airblade/vim-rooter'
let g:rooter_silent_chdir = 0
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_resolve_links = 1
let g:rooter_patterns = [
			\ '.gitignore',
			\ '.git',
			\ '.git/',
			\ 'package.json',
			\ 'composer.json',
			\ 'Doxyfile'
			\ ]
let g:rooter_targets="*.cpp,*.cxx,*.c,*.hxx,*.hpp,*.java,*.py,*.adoc,*.md,*.dot,*.js,*.html,*.css,*.less,*.sass,*.php"

" }}}

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

" Chiel92/vim-autoformat {{{
Plug 'Chiel92/vim-autoformat' , { 'on' : 'Autoformat' }
" }}}
"
"vim-scripts/SyntaxComplete {{{
Plug 'vim-scripts/SyntaxComplete', { 'on' : [] }

augroup load_syntaxcomplete
	autocmd!
	autocmd InsertEnter * call plug#load('SyntaxComplete')
				\ | set completefunc=syntaxcomplete#Complete
				\ | autocmd! load_syntaxcomplete
augroup END
"}}}
"
"mileszs/ack.vim {{{
Plug 'mileszs/ack.vim', { 'on' : ['Ack','LAck'] }
nnoremap <leader>f :Ack! 
if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif
let g:ack_use_dispatch = 1
"}}}

"nelstrom/vim-qargs {{{
Plug 'nelstrom/vim-qargs' , { 'on' : ['Qargs'] }
"}}}

" itchyny/lightline.vim {{{
Plug 'itchyny/lightline.vim'
" }}}

" ludovicchabant/vim-gutentags {{{
Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_enabled=0
augroup autoToggleGutentags
	autocmd!
	autocmd! BufEnter * call AutoToggleGutenTags()
augroup END

function! AutoToggleGutenTags()
	" activate gutentags only when in a git repository
	if exists('*fugitive#head') && !empty(fugitive#head())
		let g:gutentags_enabled=1
	else
		let g:gutentags_enabled=0
	endif
endfunction
" }}}

" mhinz/vim-startify {{{
Plug 'mhinz/vim-startify'
" }}}

" tyru/open-browser.vim {{{
Plug 'tyru/open-browser.vim' , { 'on' : 
			\ ['OpenBrowser',
			\ 'OpenBrowserSearch',
			\ 'OpenBrowserSmartSearch',
			\ 'QuickRun']}

Plug 'tyru/open-browser.vim' 
nmap <leader>b :OpenBrowserSmartSearch
command! -complete=file -nargs=1 OpenBrowserLocalFile execute "OpenBrowser" "file:///" . expand('%:p:h') . '/' . expand('<args>')

let g:openbrowser_search_engines = extend(
			\ get(g:, 'openbrowser_search_engines', {}),
			\ {
			\	't': 'http://www.wordreference.com/enit/{query}',
			\	'b': 'http://www.baidu.com/s?wd={query}&rsv_bp=0&rsv_spt=3&inputT=2478',
			\	'github': 'http://github.com/search?q={query}',
			\	'g': 'http://google.com/search?q={query}',
			\	'w': 'http://en.wikipedia.org/wiki/{query}',
			\ },
			\ 'keep'
			\)

let g:openbrowser_browser_commands =
			\[
			\ {"name": "x-www-browser",
			\  "args": ["{browser}", "{uri}"]},
			\ {"name": "google-chrome-stable",
			\  "args": ["{browser}", "{uri}"]},
			\ {"name": "chromium-browser",
			\  "args": ["{browser}", "{uri}"]},
			\ {"name": "firefox",
			\  "args": ["{browser}", "{uri}"]},
			\ {"name": "w3m",
			\  "args": ["{browser}", "{uri}"]},
			\ {"name": "xdg-open",
			\  "args": ["{browser}", "{uri}"]},
			\]

" }}}

" thinca/vim-quickrun {{{
Plug 'thinca/vim-quickrun' , { 'on': 'QuickRun' }
nnoremap <leader>r :QuickRun<cr>
nnoremap <expr> <leader>R QuickRunMapping()
function! QuickRunMapping()
	return ":QuickRun " . &filetype . "/"
endfunction

let g:quickrun_config = {
			\ 'plantuml': {
			\ 'exec': 'x-www-browser %s',
			\ 'outputter': 'null',
			\ 'runner': 'vimproc',
			\},
			\ 'asciidoc': {
			\ 'exec': 'x-www-browser %s',
			\ 'outputter': 'null',
			\ 'runner': 'vimproc',
			\},
			\ 'asciidoc/pdf': {
			\ 'command': 'asciidoctor-pdf',
			\ 'cmdopt': '-o -',
			\ 'exec': '%c %o %s | zathura -',
			\ 'outputter': 'null',
			\ 'runner': 'vimproc',
			\},
			\ 'asciidoc/html': {
			\ 'command': 'asciidoctor',
			\ 'cmdopt': '-o -',
			\ 'outputter': 'browser',
			\ 'runner': 'vimproc',
			\},
			\ 'markdown': {
			\ 'exec': 'x-www-browser %s',
			\ 'outputter': 'null',
			\ 'runner': 'vimproc',
			\},
			\ 'html': {
			\ 'exec': 'x-www-browser %s',
			\ 'outputter': 'null',
			\ 'runner': 'vimproc',
			\},
			\}
" }}}

" dominikduda/vim_current_word {{{
Plug 'dominikduda/vim_current_word'
let g:vim_current_word#enabled=1
let g:vim_current_word#highlight_twins = 1
let g:vim_current_word#highlight_current_word = 1
" }}}

" {{{ cs/alternate-file.vim
Plug 'cs/alternate-file.vim'
" }}}
"
" {{{ vim-scripts/a.vim
Plug 'vim-scripts/a.vim', { 'on': 'A' }
" }}}

" metakirby5/codi.vim {{{
Plug 'metakirby5/codi.vim', { 'on': ['Codi', 'CodiUpdate'] }
autocmd! User codi.vim call s:SetCorrectPermissionCodi()
function! s:SetCorrectPermissionCodi()
	if !has('nvim')
		if empty(glob('/tmp/cmd'))
			call system('touch /tmp/cmd')
		endif
		call system('chmod u+x /tmp/cmd')
	endif
endfunction
" }}}
" set modeline
" vim: foldlevel=0 foldmethod=marker
