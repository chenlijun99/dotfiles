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
set clipboard=unnamedplus
if has('nvim-0.10')
	" Configure OSC-52 integration
	lua << EOF
-- clipboard overrides is needed as Alacritty does not support runtime OSC 52 detection.
-- We need to customize the clipboard depending on whether in tmux, in SSH_TTY or not.
--  In Tmux, there are 2 clipboard providers
--  1. Tmux
--  2. OSC52 should also work by default.
--  In SSH_TTY, OSC 52 should work, but needs to be overridden as I use Alacritty.
--  In local (not SSH session), Default clipboard providers can be used (e.g. wl-copy).
--
--  You can test OSC 52 in terminal by using following in your terminal -
--  printf $'\e]52;c;%s\a' "$(base64 <<<'hello world')"

local tmux_natively_supports_clipboard = vim.env.TERM_PROGRAM == "tmux" 
if tmux_natively_supports_clipboard then
  -- Keep only numbers using gsub.
  -- Tmux >= 3.3 supports passthrough
  does_tmux_support_passthrough = vim.env.TERM_PROGRAM_VERSION:gsub("%D", "") >= "33"
  tmux_natively_supports_clipboard = tmux_natively_supports_clipboard and does_tmux_support_passthrough
end

-- Tmux is its own clipboard provider which directly works.
-- Assuming OSC 52 support + passthrough is enabled.
-- Still, paste doesn't work.
-- It doesn't seem related to alacritty.
-- I tried setting `osc52 = "CopyPaste"` (the default is `CopyOnly`).
-- It still doesn't work.
-- But I guess I can live with "Ctrl-Shift-v". It is more secure and 
-- anyway only copying was the more annoying part.
-- TMUX documentation about its clipboard - https://github.com/tmux/tmux/wiki/Clipboard#the-clipboard

if vim.env.SSH_TTY and not tmux_natively_supports_clipboard then
   -- Alacritty does not support runtime OSC 52 detection
   -- So we can't rely on `set clipboard=` and then have Neovim
   -- automatically enable OSC 52-based clipboard.
   --
   -- Also, we want to use OSC52 for only copying.
   -- For pasting we'll just use "Ctrl-Shift-v".
   local function paste()
     return { vim.fn.split(vim.fn.getreg(""), "\n"),       vim.fn.getregtype("") }
   end
   local osc52 = require("vim.ui.clipboard.osc52")
   vim.g.clipboard = {
     name = "OSC 52",
     copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
   }
 end
EOF
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

" To make Neovim work with transparent terminals.
" NOTE: this works okay-ish since I use the same colorscheme on my terminal
" and on Neovim.
"
" Update: No, let's comment it out. I don't work well this way, it's too 
" distracting.
" 
" highlight Normal guibg=NONE ctermbg=NONE
" highlight NormalNC guibg=NONE ctermbg=NONE

" I prefer these things to be non transparent.
"
" highlight SignColumn ctermbg=NONE ctermfg=NONE guibg=NONE
" highlight NonText ctermbg=none guibg=NONE
"
" Used for some floating windows
" highlight Pmenu ctermbg=NONE ctermfg=NONE guibg=NONE
" highlight FloatBorder ctermbg=NONE ctermfg=NONE guibg=NONE
" highlight NormalFloat ctermbg=NONE ctermfg=NONE guibg=NONE
" highlight TabLine ctermbg=None ctermfg=None guibg=None 


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
" Languages that I use
set spelllang=en,it,cjk

set list listchars=tab:\▸\ 

set fileencodings=ucs-bom,utf-8,default,latin,gb18030,gbk,gk2312

" set modeline 
" vim: foldlevel=0 foldmethod=marker
