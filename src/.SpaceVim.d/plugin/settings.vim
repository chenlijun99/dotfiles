" set default clipboard as system clipboard
set clipboard=unnamedplus
" show a vertical line at the 80th column
" set colorcolumn=80

" for vimdiff use vertical split
set diffopt+=vertical

" Ui {{{
" since there is already lightline which shows the current mode,
" leave space for echodoc
set noshowmode

" keep cursor always at the center of the window when scrolling
set scrolloff=99

" draw always signcolumn
set signcolumn=yes

set list listchars=tab:\▸\ 
" }}}

" Gui {{{
set guioptions=a
" }}}

" Completion {{{
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

" Folding {{{
" enable folding
set foldenable
set foldmethod=indent
set foldcolumn=1
" when enter in a buffer, no folds are closed
set foldlevelstart=99
set foldnestmax=5
"}}}

" Undo {{{
let s:undo_dir = $HOME . "/.cache/vim/undo"
if !isdirectory(s:undo_dir)
	call system("mkdir -p" . s:undo_dir)
endif
let &undodir=s:undo_dir
set undofile
" }}}

" Encoding {{{
set fileencodings=ucs-bom,utf-8,default,latin,gb18030,gbk,gk2312
" }}}


" set modeline 
" vim: foldlevel=0 foldmethod=marker
