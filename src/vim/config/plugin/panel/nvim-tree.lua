function NvimTreeOpenOrFindFile()
	if vim.api.nvim_eval("expand('%:p') == ''") == 1 then
		-- If file not saved in file system, open nvim tree normally
		vim.cmd("NvimTreeOpen")
	else
		local api = require("nvim-tree.api")
		api.tree.find_file({
			open = true,
			focus = true,
			update_root = true,
		})
	end
end

local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end


  -- Default mappings not inserted as:
  --  remove_keymaps = true
  --  OR
  --  view.mappings.custom_only = true


  -- Mappings migrated from view.mappings.list
  --
  -- You will need to insert "your code goes here" for any mappings with a custom action_cb
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
  vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', 'x', api.node.navigate.parent_close, opts('Close Directory'))
  vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('n', 'i', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  vim.keymap.set('n', 'I', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  vim.keymap.set('n', '<c-l>', api.tree.reload, opts('Refresh'))
  vim.keymap.set('n', 'bf', api.live_filter.start, opts('Live filter start'))
  vim.keymap.set('n', 'bF', api.live_filter.clear, opts('Live filter clear'))
  vim.keymap.set('n', 'ma', api.fs.create, opts('Create'))
  vim.keymap.set('n', 'md', api.fs.remove, opts('Delete'))
  vim.keymap.set('n', 'mD', api.fs.trash, opts('Trash'))
  vim.keymap.set('n', 'mr', api.fs.rename, opts('Rename'))
  vim.keymap.set('n', 'mR', api.fs.rename_sub, opts('Rename: Omit Filename'))
  vim.keymap.set('n', 'mx', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 'mm', api.fs.cut, opts('Cut'))
  vim.keymap.set('n', 'mc', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('n', 'mp', api.fs.paste, opts('Paste'))
  vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
  vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'zM', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', 'zR', api.tree.expand_all, opts('Expand all'))
  vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
  vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
  vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
  -- Override default window width resize mapping with NvimTreeResize.
  -- This way window resizes are persisted even if NvimTree is resized.
  vim.keymap.set("n", "<c-w>>", "<cmd>execute \"NvimTreeResize +\" . (v:count1)<cr>", opts('Enlarge window'))
  vim.keymap.set("n", "<c-w><", "<cmd>execute \"NvimTreeResize -\" . (v:count1)<cr>", opts('Shrink window'))
end

return {
	{
		"kyazdani42/nvim-tree.lua",
		dependencies = { "kyazdani42/nvim-web-devicons" },
		keys = {
			{
				"<leader>pf",
				"<cmd>lua NvimTreeOpenOrFindFile()<CR>",
				desc = "Filetree explorer",
			},
		},
		config = function()
			require("nvim-tree").setup({
				on_attach = on_attach,
				-- Disable auto refresh on save, since it introduces lags
				auto_reload_on_write = false,
				filters = {
					dotfiles = false,
				},
				respect_buf_cwd = true,
				disable_netrw = false,
				hijack_netrw = true,
				open_on_tab = false,
				hijack_cursor = false,
				hijack_unnamed_buffer_when_opening = false,
				update_cwd = true,
				update_focused_file = {
					-- Doesn't work well with nvim-hop multi-window jump
					enable = false,
					update_cwd = false,
				},
				view = {
					side = "left",
					width = 25,
				},
				renderer = {
					root_folder_label = false,
					add_trailing = false,
					highlight_git = false,
					highlight_opened_files = "none",
					root_folder_modifier = table.concat({
						":t:gs?$?/..",
						string.rep(" ", 1000),
						"?:gs?^??",
					}),
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
						},
					},
					indent_markers = {
						enable = true,
					},
				},
			})
		end,
	},
}
