" enable vim features, which are not supported by vi
set nocompatible

if has('nvim')
	set inccommand=split
endif

set lazyredraw
set updatetime=300

set nobackup
set nowritebackup

" don't give |ins-completion-menu| messages.
set shortmess+=c

" set backspace behavior as we would normally expect
set backspace=indent,eol,start

" set default clipboard as system clipboard
if has('nvim-0.10')
	" only set clipboard if not in ssh, to make sure the OSC 52
	" integration works automatically. Requires Neovim >= 0.10.0
	if empty($SSH_TTY)
		set clipboard=unnamedplus
	else
		set clipboard=
	endif
else
	set clipboard=unnamedplus
endif

" enable the use of mouse for [a]ll the mode
set mouse=a

" show a menu of possible completion, when pressing tab in command mode
set wildmenu
set wildmode=full

" highlight the current line
set cursorline

" show line number
set number

" show the line number distance of each line relative to the current one
set relativenumber

" show a vertical line at the 80th column
set colorcolumn=80

" don't close buffer when it's abandoned, just leave it hidden
set hidden

set timeoutlen=500

" since there is already lightline which shows the current mode,
" leave space for echodoc
set noshowmode

set scrolloff=99

" draw always signcolumn
set signcolumn=yes

" for vimdiff use vertical split
set diffopt+=vertical
if has('patch-8.2.2490') || has('nvim-0.5')
	set diffopt+=followwrap
endif

" While the performance problems that I suffered don't seem to be related to
" shell setting, it seems that to many this setting indeed causes performance
" problem. See
" 
" * Fugitive: https://github.com/tpope/vim-fugitive/issues/1492
" * nvim-tree: https://github.com/kyazdani42/nvim-tree.lua#performance-issues
"
" So let's take the suggetion and set bash as shell.
"
let &shell="/usr/bin/env bash"

if has('nvim-0.9')
	" Since Neovim 0.9, we have a more secure implementation of exrc
	" So we can really use it if we're using Neovim >=0.9.
	set exrc
endif

" wrap {{{
" don't wrap even when a line is longer than the width of the window
set nowrap

" `wrap` is enabled in ftplugin of some specific prose oriented languages
" Options that I want when wrap is enabled

" Break wrapped lines only in specific location (word boundaries)
set linebreak
set breakindent
" }}}

" completion {{{
" show the completion as complete as possible
set completeopt+=longest

" do not use open a preview window of completion (it's laggy)
set completeopt-=preview

" do not automatically select to first item
set completeopt+=noselect
" }}}

" Search {{{
" highlight searched pattern
set hlsearch

" highlight searched pattern as it's typed
set incsearch
set ignorecase

" when the search pattern contains uppercase chars, then do not ignore case
set smartcase
"}}}

" Indent {{{
set autoindent
set tabstop=4
set shiftwidth=4
set noexpandtab
"}}}

" Colorscheme & Font {{{
" NOTE: first set background and then set the colorscheme.
" If the order is inverted, the colorscheme will be sourced twice.
set background=dark
colorscheme gruvbox

set t_Co=256
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
set termguicolors
set guifont=Monospace\ 13
"}}}

" Folding {{{
" enable folding
set foldenable
set foldmethod=indent
set foldcolumn=1
" when enter in a buffer, no folds are closed
set foldlevelstart=99
set foldnestmax=5
"}}}

" Gui {{{
set guioptions=a
" }}}

" Undo {{{
" Neovim's default undo dir is "$XDG_DATA_HOME/nvim/undo/", which is OK.
" Vim's default undo dir is relative to CWD, which I don't want.
" Need to keep undo files from Vim and Neovim separate because they are incompatible.
if !has('nvim')
	let s:undo_dir = $HOME . "/.local/share/nvim/undo-vim" 
	if !isdirectory(s:undo_dir)
		call system("mkdir " . s:undo_dir)
	endif
	let &undodir=s:undo_dir
endif
set undofile

" Disable undo persistence for ApprovalTests.cpp files
autocmd BufReadPre *.approved.txt setlocal noundofile
" }}}

" Terminal {{{
" }}}

set spellfile=$HOME/.vim/spell/myspell.utf-8.add

set list listchars=tab:\▸\ 

set fileencodings=ucs-bom,utf-8,default,latin,gb18030,gbk,gk2312


" set modeline 
" vim: foldlevel=0 foldmethod=marker
