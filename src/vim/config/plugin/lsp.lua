which_key_map.l = { name = "+lsp" }

local nvim_lspfuzzy = {
	"ojroques/nvim-lspfuzzy",

	config = function()
		local opts = { noremap = true }

		which_key_map.l.d = "Show buffer diagnostics"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>ld",
			"<cmd>LspDiagnostics 0<CR>",
			opts
		)

		which_key_map.l.D = "Show all diagnostics"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>lD",
			"<cmd>LspDiagnosticsAll<CR>",
			opts
		)

		require("lspfuzzy").setup({})
	end,
}

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"folke/neodev.nvim",
				opts = { experimental = { pathStrict = true } },
			},
			nvim_lspfuzzy,
		},
		---@class PluginLspOpts
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, prefix = "●" },
				severity_sort = true,
			},
			autoformat = false,
			-- LSP Server Settings
			---@type lspconfig.options
			servers = {
				jsonls = {},
				lua_ls = {
					-- mason = false, -- set to false if you don't want this server to be installed with mason
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			},
			-- you can do any additional lsp server setup here
			-- return true if you don't want this server to be setup with lspconfig
			---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
			setup = {
				-- example to setup with typescript.nvim
				-- tsserver = function(_, opts)
				--   require("typescript").setup({ server = opts })
				--   return true
				-- end,
				-- Specify * to use this function as a fallback for any server
				-- ["*"] = function(server, opts) end,
			},
		},
		---@param opts PluginLspOpts
		config = function()
			local opts = { noremap = true }

			which_key_map_g.H = "Show diagnostics"
			vim.api.nvim_set_keymap(
				"n",
				"gH",
				"<cmd>lua vim.diagnostic.open_float()<CR>",
				opts
			)

			which_key_map.l.r = "Rename"
			vim.api.nvim_set_keymap(
				"n",
				"<leader>lr",
				"<cmd>lua vim.lsp.buf.rename()<CR>",
				opts
			)

			which_key_map.l.a = "Code action"
			vim.api.nvim_set_keymap(
				"n",
				"<leader>la",
				"<cmd>lua vim.lsp.buf.code_action()<CR>",
				opts
			)

			which_key_map.l.s = "Document symbols"
			vim.api.nvim_set_keymap(
				"n",
				"<leader>ls",
				"<cmd>lua vim.lsp.buf.document_symbol()<CR>",
				opts
			)
			which_key_map.l.S = "Workspace symbols"
			vim.api.nvim_set_keymap(
				"n",
				"<leader>lS",
				"<cmd>lua vim.lsp.buf.workspace_symbol()<CR>",
				opts
			)

			which_key_map.l.f = "Format"
			vim.api.nvim_set_keymap(
				"n",
				"<leader>lf",
				"<cmd>lua vim.lsp.buf.format{ async = true }<CR>",
				opts
			)
			vim.api.nvim_set_keymap(
				"v",
				"<leader>lf",
				"<cmd>lua vim.lsp.buf.range_formatting()<CR>",
				opts
			)

			which_key_map.l.i = "Code action"
			vim.api.nvim_set_keymap("n", "<leader>li", "<cmd>LspInfo<cr>", opts)

			which_key_map_global_previous.d = "Previous lsp diagnostic"
			vim.api.nvim_set_keymap(
				"n",
				"[d",
				"<cmd>lua vim.diagnostic.goto_prev()<CR>",
				opts
			)

			which_key_map_global_next.d = "Next lsp diagnostic"
			vim.api.nvim_set_keymap(
				"n",
				"]d",
				"<cmd>lua vim.diagnostic.goto_next()<CR>",
				opts
			)

			which_key_map_g.D = "Goto declaration"
			vim.api.nvim_set_keymap(
				"n",
				"gD",
				"<cmd>lua vim.lsp.buf.declaration()<CR>",
				opts
			)

			which_key_map_g.d = "Goto definition"
			vim.api.nvim_set_keymap(
				"n",
				"gd",
				"<cmd>lua vim.lsp.buf.definition()<CR>",
				opts
			)

			which_key_map_g.h = "Hover"
			vim.api.nvim_set_keymap(
				"n",
				"gh",
				"<cmd>lua vim.lsp.buf.hover()<CR>",
				opts
			)

			which_key_map_g.i = "Goto implementation"
			vim.api.nvim_set_keymap(
				"n",
				"gi",
				"<cmd>lua vim.lsp.buf.implementation()<CR>",
				opts
			)

			which_key_map_g.r = "References"
			vim.api.nvim_set_keymap(
				"n",
				"gr",
				"<cmd>lua vim.lsp.buf.references()<CR>",
				opts
			)

			vim.api.nvim_set_keymap(
				"n",
				"<C-k>",
				"<cmd>lua vim.lsp.buf.signature_help()<CR>",
				opts
			)
		end,
	},
}
