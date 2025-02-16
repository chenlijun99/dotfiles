return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"<leader>ac",
				"<cmd>CodeCompanionChat Toggle<cr>",
				mode = { "n", "v", },
				desc = "Chat with LLM",
			},
		},
		config = function()
			require("codecompanion").setup({
				strategies = {
					chat = {
						adapter = "gemini",
						slash_commands = {
							["file"] = {
								-- Location to the slash command in CodeCompanion
								callback = "strategies.chat.slash_commands.file",
								description = "Select a file using fzf-lua",
								opts = {
									provider = "fzf_lua",
									contains_code = true,
								},
							},
							["buffer"] = {
								callback = "strategies.chat.slash_commands.buffer",
								description = "Select buffer use fzf-lua",
								opts = {
									provider = "fzf_lua",
									contains_code = true,
								},
							},
							["symbols"] = {
								callback = "strategies.chat.slash_commands.symbols",
								description = "Insert symbols for a selected file",
								opts = {
									contains_code = true,
									provider = "fzf_lua",
								},
							},
						},
						-- Override default keymaps of the Chat buffer
						keymaps = {
							close = {
								modes = {
									n = "<leader>aC",
								},
								index = 4,
								callback = "keymaps.close",
								description = "Close Chat",
							},
						},
					},
					inline = {
						adapter = "gemini",
					},
				},
				display = {
					chat = {
						window = {
							layout = "vertical",
							position = "right",
							border = "single",
							height = 0.8,
							width = 0.45,
							relative = "editor",
						},
					},
				},
				adapters = {
					gemini = function()
						return require("codecompanion.adapters").extend(
							"gemini",
							{
								env = {
									api_key = "cmd: cat $HOME/.config/sops-nix/secrets/GEMINI_API_KEY",
								},
							}
						)
					end,
				},
			})
		end,
	},
}
