local LuaSnip = {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"rafamadriz/friendly-snippets",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_snipmate").lazy_load()
		end,
	},
	opts = {
		history = true,
		delete_check_events = "TextChanged",
	},
}

local kind_icons = {
	Text = "",
	Method = "m",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

return {
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			LuaSnip,
		},
		opts = function()
			local cmp = require("cmp")

			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api
							.nvim_buf_get_lines(0, line - 1, line, true)[1]
							:sub(col, col)
							:match("%s")
						== nil
			end

			local luasnip = require("luasnip")
			return {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
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
					["<S-Tab>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							-- use this instead of fallback()
							-- we want shift table's fallback to delete a tab
							local key = vim.api.nvim_replace_termcodes(
								"<c-h>",
								true,
								true,
								true
							)
							vim.api.nvim_feedkeys(key, "n", true)
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "luasnip" },
				}, {
					{ name = "path" },
					{
						name = "buffer",
						option = {
							-- So that accented characterers are also completed https://github.com/hrsh7th/cmp-buffer/issues/11
							keyword_pattern = [[\k\+]],
						},
					},
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind =
							string.format("%s", kind_icons[vim_item.kind])
						vim_item.menu = ({
							buffer = "[buf]",
							nvim_lsp = "[lsp]",
							nvim_lua = "[api]",
							luasnip = "[snip]",
							path = "[path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				window = {
					--completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = {
						hl_group = "LspCodeLens",
					},
				},
			}
		end,
		config = function()
			local cmp = require("cmp")
			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					-- You can specify the `cmp_git` source if you were installed it.
					{ name = "cmp_git" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
}
