which_key_map.l = { name = "+lsp" }

--[[
This plugin takes care of managing the installation of LSP server.
Furthermore, it takes care of setting up all the installed server.
--]]
Plug("williamboman/nvim-lsp-installer", {
	config = function()
		local lsp_installer = require("nvim-lsp-installer")

		-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
		-- or if the server is already installed).
		lsp_installer.on_server_ready(function(server)
			local opts = {
				-- This will be the default in neovim 0.7+
				debounce_text_changes = 150,
			}

			-- (optional) Customize the options passed to the server
			-- if server.name == "tsserver" then
			--     opts.root_dir = function() ... end
			-- end

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

Plug("neovim/nvim-lspconfig", {
	config = function()
		local opts = { noremap = true }

		which_key_map.l.d = "Diagnostics"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>ld",
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

		which_key_map.l.f = "Format"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>lf",
			"<cmd>lua vim.lsp.buf.formatting()<CR>",
			opts
		)

		which_key_map.l.i = "Code action"
		vim.api.nvim_set_keymap(
			"n",
			"<leader>li",
			"<cmd>LspInfo<cr>",
			opts
		)

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
