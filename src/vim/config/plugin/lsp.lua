vim.cmd([[
let g:which_key_map.l = { 'group_name' : '+lsp' }
]])

return {
	{
		"neovim/nvim-lspconfig",
		-- Hmm, with LazyFile-based lazy loading
		-- for some filetypes the LSP does not attach to the the first
		-- opened buffer.
		-- Running `:e` works, but it's annoying.
		--
		-- Experienced this behaviour with Python (pyright) and Typst (tinymist)
		config = function()
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, prefix = "●" },
				severity_sort = true,
			})

			local default_lsp = {
				"lua_ls",
				"clangd",
				"ocamllsp",
				"cmake",
				"pyright",
				-- TypeScript
				"ts_ls",
				-- Nix
				"nil_ls",
				-- Typst
				"tinymist",
			}

			local function enable_default_lsp()
				-- Enable LSPs after .nvim.lua is loaded
				-- Enable only the default LSPs whose supported filetypes
				-- are not already supported by the LSPs that are already enabled.
				local covered_filetypes = {}
				for name in vim.spairs(vim.lsp._enabled_configs) do
					for _, ft in pairs(vim.lsp.config[name].filetypes) do
						covered_filetypes[ft] = true
					end
				end
				local lsp_to_enable = {}
				for _, lsp in pairs(default_lsp) do
					for _, ft in pairs(vim.lsp.config[lsp].filetypes) do
						if covered_filetypes[ft] == true then
							-- already covered
							goto skip_enable
						end
					end
					lsp_to_enable[lsp] = true

					::skip_enable::
				end
				lsp_to_enable = vim.tbl_keys(lsp_to_enable)

				if #lsp_to_enable > 0 then
					vim.notify(
						"[Clj] LSP: Enabling additional default LSPs "
							.. table.concat(lsp_to_enable, ", ")
					)
					vim.lsp.enable(lsp_to_enable)
				end
			end

			local lsp_augroup =
				vim.api.nvim_create_augroup("clj-lsp-config", { clear = true })

			-- Enable LSPs on VimEnter, when potential .nvim.lua
			-- has also been loaded
			vim.api.nvim_create_autocmd("VimEnter", {
				group = lsp_augroup,
				callback = enable_default_lsp,
			})

			if false then
				-- I'm not sure I like this behaviour.
				-- It'll lead to a lot of LSP server restart if we switch
				-- between workspaces in a single Vim instance.
				-- Exclude this for now.

				-- Autocmd to stop LSPs before .nvim.lua is loaded
				vim.api.nvim_create_autocmd("User", {
					group = lsp_augroup,
					pattern = "CljLoadExrcPre",
					callback = function()
						-- Disable everything that is enabled now
						vim.lsp.enable(
							vim.tbl_keys(vim.lsp._enabled_configs),
							false
						)
						vim.notify(
							"[Clj] LSP: Disable all LSPs before loading exrc"
						)
					end,
				})

				vim.api.nvim_create_autocmd("User", {
					group = lsp_augroup,
					pattern = "CljLoadExrcPost",
					callback = enable_default_lsp,
				})
			end

			local function opts(desc)
				return {
					desc = "LSP: " .. desc,
					noremap = true,
				}
			end

			vim.api.nvim_set_keymap(
				"n",
				"gH",
				"<cmd>lua vim.diagnostic.open_float()<CR>",
				opts("Show diagnostics")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lr",
				"<cmd>lua vim.lsp.buf.rename()<CR>",
				opts("Rename")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>la",
				"<cmd>lua vim.lsp.buf.code_action()<CR>",
				opts("Code action")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>ls",
				"<cmd>lua vim.lsp.buf.document_symbol()<CR>",
				opts("Document symbols")
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>lS",
				"<cmd>lua vim.lsp.buf.workspace_symbol()<CR>",
				opts("Workspace symbols")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lci",
				"<cmd>lua vim.lsp.buf.incoming_calls()<CR>",
				opts("Incoming calls")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lco",
				"<cmd>lua vim.lsp.buf.outgoing_calls()<CR>",
				opts("Outgoing calls")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lt",
				"<cmd>lua vim.lsp.buf.typehierarchy('subtypes')<CR>",
				opts("Subtypes")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lT",
				"<cmd>lua vim.lsp.buf.typehierarchy('supertypes')<CR>",
				opts("Supertypes")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>li",
				"<cmd>LspInfo<cr>",
				opts("Code action")
			)

			vim.keymap.set("n", "<leader>li", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end, opts("Toggle inlay hints"))

			vim.api.nvim_set_keymap(
				"n",
				"<leader>ld",
				"<cmd>lua vim.diagnostic.setloclist()<CR>",
				opts("Buffer diagnostics")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>lD",
				"<cmd>lua vim.diagnostic.setqflist()<CR>",
				opts("All diagnostics")
			)

			vim.api.nvim_set_keymap(
				"n",
				"[d",
				"<cmd>lua vim.diagnostic.goto_prev()<CR>",
				opts("Previous diagnostic")
			)

			vim.api.nvim_set_keymap(
				"n",
				"]d",
				"<cmd>lua vim.diagnostic.goto_next()<CR>",
				opts("Next diagnostic")
			)

			vim.api.nvim_set_keymap(
				"n",
				"gD",
				"<cmd>lua vim.lsp.buf.declaration()<CR>",
				opts("Goto declaration")
			)

			vim.api.nvim_set_keymap(
				"n",
				"gd",
				"<cmd>lua vim.lsp.buf.definition()<CR>",
				opts("Goto definition")
			)

			vim.api.nvim_set_keymap(
				"n",
				"gh",
				"<cmd>lua vim.lsp.buf.hover()<CR>",
				opts("Hover")
			)

			vim.api.nvim_set_keymap(
				"n",
				"gi",
				"<cmd>lua vim.lsp.buf.implementation()<CR>",
				opts("Goto implementation")
			)

			vim.api.nvim_set_keymap(
				"n",
				"gr",
				"<cmd>lua vim.lsp.buf.references()<CR>",
				opts("References")
			)

			vim.api.nvim_set_keymap(
				"n",
				"<C-k>",
				"<cmd>lua vim.lsp.buf.signature_help()<CR>",
				opts("Signature help")
			)
		end,
	},
}
