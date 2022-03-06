Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-cmdline")
Plug("L3MON4D3/LuaSnip")
Plug("hrsh7th/nvim-cmp", {
	config = function()
		-- Setup nvim-cmp.
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		cmp.setup({
			mapping = {
				["<C-b>"] = cmp.mapping(
					cmp.mapping.scroll_docs(-4),
					{ "i", "c" }
				),
				["<C-f>"] = cmp.mapping(
					cmp.mapping.scroll_docs(4),
					{ "i", "c" }
				),
				["<C-Space>"] = cmp.mapping(
					cmp.mapping.complete(),
					{ "i", "c" }
				),
				-- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
				["<C-y>"] = cmp.config.disable,
				["<C-e>"] = cmp.mapping({
					i = cmp.mapping.abort(),
					c = cmp.mapping.close(),
				}),
				-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Set configuration for specific filetype.
		cmp.setup.filetype("gitcommit", {
			sources = cmp.config.sources({
				-- You can specify the `cmp_git` source if you were installed it.
				{ name = "cmp_git" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline("/", {
			sources = {
				{ name = "buffer" },
			},
		})

		-- Setup lspconfig.
		local capabilities = require("cmp_nvim_lsp").update_capabilities(
			vim.lsp.protocol.make_client_capabilities()
		)
		-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
		require("lspconfig")["clangd"].setup({
			capabilities = capabilities,
		})
	end,
})
