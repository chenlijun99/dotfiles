vim.cmd([[
let g:which_key_map.l = { 'group_name' : '+lsp' }
]])

return {
	{
		"neovim/nvim-lspconfig",
		event = "LazyFile",
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = { spacing = 4, prefix = "●" },
				severity_sort = true,
			},
			-- Automatically format on save
			autoformat = true,
			-- options for vim.lsp.buf.format
			-- `bufnr` and `filter` is handled by the LazyVim formatter,
			-- but can be also overridden when specified
			format = {
				formatting_options = nil,
				timeout_ms = nil,
			},
			-- LSP Server Settings
			---@type lspconfig.options
			servers = {
				lua_ls = {},
				clangd = {
					-- Workaround "warning: multiple different client offset_encodings
					-- detected for buffer" Which is caused by the fact that Neovim
					-- currently doesn't support multipe LSP offset_encodings settings in the same buffer.
					-- But we use both clangd and null.ls (clang-format, cppcheck,
					-- etc), but they have conflicting offset_encodings apparently.
					-- See
					-- * https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
					-- * https://github.com/neovim/neovim/pull/16694#issuecomment-996947306: where I got the workaround
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
				},
				ocamllsp = {},
				cmake = {},
				pyright = {},
				ts_ls = {},
				nil_ls = {},
				tinymist = {
					--- todo: these configuration from lspconfig maybe broken
					single_file_support = true,
					root_dir = function()
						return vim.fn.getcwd()
					end,
					--- See [Tinymist Server Configuration](https://github.com/Myriad-Dreamin/tinymist/blob/main/Configuration.md) for references.
					settings = {},
				},
				-- Dunno why, but causes some error messages from Neovim
				-- when opening markdown files in non-git folders.
				-- Anyway, I need it only for Obsidian. So I enable it only
				-- in the obsidian vault using .nvim.lua.
				-- markdown_oxide = {},
				rust_analyzer = {
					on_attach = function(client, bufnr)
						require("completion").on_attach(client)
						vim.lsp.inlay_hint.enable(bufnr)
					end,
					settings = {
						["rust-analyzer"] = {
							imports = {
								granularity = {
									group = "module",
								},
								prefix = "self",
							},
							cargo = {
								buildScripts = {
									enable = true,
								},
							},
							procMacro = {
								enable = true,
							},
						},
					},
				},
			},
			setup = {},
		},
		config = function(_, opts)
			local cmp_nvim_lsp_capabilities =
				require("cmp_nvim_lsp").default_capabilities(
					vim.lsp.protocol.make_client_capabilities()
				)

			local servers = opts.servers

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(cmp_nvim_lsp_capabilities),
				}, servers[server] or {})

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			for server, server_opts in pairs(servers) do
				if server_opts then
					setup(server)
				end
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
