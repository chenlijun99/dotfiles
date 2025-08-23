return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<c-p>",
			function()
				local in_git = vim.api.nvim_eval(
					"exists('*FugitiveHead') && !empty(FugitiveHead())"
				)
				if in_git then
					require("fzf-lua").files()
				else
					require("fzf-lua").git_files()
				end
			end,
			desc = "fuzzy files",
		},
		{
			"<c-f>",
			function()
				require("fzf-lua").grep_project()
			end,
			desc = "fuzzy search",
		},
		{
			"<c-b>",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "fuzzy buffers",
		},
		{
			"<leader>fp",
			function()
				require("fzf-lua").files()
			end,
			desc = "fuzzy files",
		},
		{
			"<leader>fP",
			function()
				require("fzf-lua").git_files({
					cmd = "git ls-files --exclude-standard --recurse-submodules",
				})
			end,
			desc = "fuzzy git (+submodules)",
		},
		{
			"<leader>ft",
			function()
				require("fzf-lua").tags()
			end,
			desc = "fuzzy tags",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").git_commits()
			end,
			desc = "fuzzy commits",
		},
		{
			"<leader>fls",
			function()
				require("fzf-lua").lsp_document_symbols()
			end,
			desc = "Document symbols",
		},
		{
			"<leader>flS",
			function()
				require("fzf-lua").lsp_live_workspace_symbols()
			end,
			desc = "Workspace symbols",
		},
	},
	lazy = false,
	config = function()
		local file_copy_path_relative_to_cwd = function(selected, opts)
			local path = require("fzf-lua").path
			local entry = path.entry_to_file(selected[1], opts)
			vim.fn.setreg("+", entry.path)
			print("Copied path: " .. entry.path)
		end

		local file_copy_path_relative_to_current_buffer = function(
			selected,
			opts
		)
			local Path = require("plenary.path")

			-- Copied from https://github.com/jhonasiv/workwork/pull/5/files
			local function relative_path(original_path, reference_path)
				-- Use plenary's make relative to clean paths
				original_path = Path:new(original_path):make_relative(".")
				reference_path = Path:new(reference_path):make_relative(".")
				local path = Path:new(original_path)
				local ref_path = Path:new(reference_path)
				local parents = path:parents()
				local ref_parents = ref_path:parents()

				local path_elements = vim.split(path.filename, "/")
				table.insert(parents, 1, original_path)
				table.insert(ref_parents, 1, reference_path)

				local result = ""
				for i, ref_parent in ipairs(ref_parents) do
					for j, par in ipairs(parents) do
						if ref_parent == par then
							if i == 1 and j == 1 then
								return ""
							end

							result = result
								.. table.concat(
									path_elements,
									"/",
									#path_elements - j + 2
								)
							return result
						end
					end

					result = "../" .. result
				end
			end

			local path = require("fzf-lua").path
			local entry = path.entry_to_file(selected[1], opts)
			local rel_path = relative_path(
				entry.path,
				Path:new(vim.api.nvim_buf_get_name(0)):parent()
			)
			vim.fn.setreg("+", rel_path)
			print("Copied path: " .. rel_path)
		end

		local opts = {
			winopts = {
				preview = {
					layout = "vertical",
				},
			},
			keymap = {
				fzf = {
					["ctrl-N"] = "next-history",
					["ctrl-P"] = "prev-history",
				},
			},
			actions = {
				files = {
					-- inherit from default config
					true,
					["ctrl-y"] = file_copy_path_relative_to_cwd,
					["ctrl-r"] = file_copy_path_relative_to_current_buffer,
				},
			},
			fzf_opts = {
				["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
			},
		}
		require("fzf-lua").setup(opts)
		-- Register as UI for vim.ui.select
		require("fzf-lua").register_ui_select()
	end,
}
