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
			local mappings_list = {
				{ key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
				{
					key = "<C-e>",
					action = "edit_in_place",
				},
				{
					key = { "O" },
					action = "edit_no_picker",
				},
				{ key = { "<2-RightMouse>", "<C-]>" },    action = "cd" },
				{ key = "<C-v>",                          action = "vsplit" },
				{ key = "<C-x>",                          action = "split" },
				{ key = "<C-t>",                          action = "tabnew" },
				{
					key = "<",
					action = "prev_sibling",
				},
				{
					key = ">",
					action = "next_sibling",
				},
				{
					key = "P",
					action = "parent_node",
				},
				{
					key = "x",
					action = "close_node",
				},
				{ key = "<Tab>", action = "preview" },
				{
					key = "K",
					action = "first_sibling",
				},
				{ key = "J",     action = "last_sibling" },
				{
					key = "i",
					action = "toggle_ignored",
				},
				{
					key = "I",
					action = "toggle_dotfiles",
				},
				{ key = "<c-l>", action = "refresh" },
				{ key = "ma",    action = "create" },
				{ key = "md",    action = "remove" },
				{ key = "mD",    action = "trash" },
				{ key = "mr",    action = "rename" },
				{ key = "mR",    action = "full_rename" },
				{ key = "mx",    action = "system_open" },
				{ key = "mm",    action = "cut" },
				{ key = "mc",    action = "copy" },
				{ key = "mp",    action = "paste" },
				{ key = "y",     action = "copy_name" },
				{ key = "Y",     action = "copy_path" },
				{
					key = "gy",
					action = "copy_absolute_path",
				},
				{
					key = "[c",
					action = "prev_git_item",
				},
				{
					key = "]c",
					action = "next_git_item",
				},
				{ key = "-",  action = "dir_up" },
				{ key = "q",  action = "close" },
				{ key = "g?", action = "toggle_help" },
				{ key = "W",  action = "collapse_all" },
				{ key = "S",  action = "search_node" },
				{
					key = "<C-k>",
					action = "toggle_file_info",
				},
				{
					key = ".",
					action = "run_file_command",
				},
			}

			require("nvim-tree").setup({
				-- Disable auto refresh on save, since it introduces lags
				auto_reload_on_write = false,
				filters = {
					dotfiles = false,
				},
				respect_buf_cwd = true,
				disable_netrw = false,
				hijack_netrw = true,
				open_on_tab = false,
				hijack_cursor = true,
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
					hide_root_folder = true,
					mappings = {
						custom_only = true,
						list = mappings_list,
					},
				},
				renderer = {
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
