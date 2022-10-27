which_key_map.l = { name = "+lsp" }

--[[
This plugin takes care of managing the installation of LSP server.
Furthermore, it takes care of setting up all the installed server.
--]]
Plug("williamboman/nvim-lsp-installer", {
	config = function()
		local lsp_installer = require("nvim-lsp-installer")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
		-- or if the server is already installed).
		lsp_installer.on_server_ready(function(server)
			-- Add also the lsp capabilities introduced by cmp_nvim_lsp
			local capabilities = cmp_nvim_lsp.default_capabilities()

			local opts = {
				-- This will be the default in neovim 0.7+
				debounce_text_changes = 150,
				capabilities = capabilities,
				on_attach = function(client)
					-- Disable formatting capabilities, as we use
					-- null-ls.nvim to do that and we don't want
					-- neovim to ask everytime which one we want
					-- to use
					client.server_capabilities.documentFormattingProvider =
						false
					client.server_capabilities.documentRangeFormattingProvider =
						false
				end,
			}

			-- (optional) Customize the options passed to the server
			-- if server.name == "tsserver" then
			--     opts.root_dir = function() ... end
			-- end

			-- Workaround "warning: multiple different client offset_encodings
			-- detected for buffer" Which is caused by the fact that Neovim
			-- currently doesn't support multipe LSP offset_encodings settings in the same buffer.
			-- But we use both clangd and null.ls (clang-format, cppcheck,
			-- etc), but they have conflicting offset_encodings apparently.
			-- See
			-- * https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
			-- * https://github.com/neovim/neovim/pull/16694#issuecomment-996947306: where I got the workaround
			if server.name == "clangd" then
				opts.capabilities.offsetEncoding = { "utf-16" }
			end

			-- This setup() function will take the provided server configuration and decorate it with the necessary properties
			-- before passing it onwards to lspconfig.
			-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			server:setup(opts)
		end)

		local opts = { noremap = true, silent = true }
		vim.api.nvim_set_keymap(
			"n",
			"<leader>lI",
			"<cmd>LspInstallInfo<CR>",
			opts
		)
		which_key_map.l.I = "Installer info"
	end,
})

Plug("ojroques/nvim-lspfuzzy", {
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
})
Plug("neovim/nvim-lspconfig", {
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
})
