-- Use light colorscheme, because it's more readable on the projector
vim.cmd("set background=light")
-- Highlight with very noticeable color the CursorLine in NvimTree so that it
-- is straightforward to know which is the current file
vim.cmd(
	"highlight NvimTreeCursorLine ctermfg=1 ctermbg=223 gui=bold guifg=#cc64f5 guibg=#b1d2e3"
)

-- Override nvim-tree width
-- Larger file tree, so that the whole file name can be seen
require"nvim-tree.view".View.width = 35
