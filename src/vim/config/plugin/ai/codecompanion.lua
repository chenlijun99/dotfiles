return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"ravitemer/codecompanion-history.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",

			-- Integration mcphub
			"ravitemer/mcphub.nvim",
			-- Integration with fidget spinner
			"j-hui/fidget.nvim",
		},
		keys = {
			{
				"<leader>ac",
				"<cmd>CodeCompanionChat Toggle<cr>",
				mode = { "n", "v" },
				desc = "Chat with LLM",
			},
			{
				"<leader>aa",
				"<cmd>CodeCompanionActions<cr>",
				mode = { "n", "v" },
				desc = "LLM actions",
			},
			{
				"<leader>ah",
				"<cmd>CodeCompanionHistory<cr>",
				mode = { "n" },
				desc = "LLM history",
			},
		},
		config = function()
			require("clj.codecompanion-helpers.fidget").init()

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
							options = {
								modes = {
									n = "<localleader>?",
								},
								callback = "keymaps.options",
								description = "Options",
								hide = true,
							},
							regenerate = {
								modes = {
									n = "<localleader>r",
								},
								index = 3,
								callback = "keymaps.regenerate",
								description = "Regenerate the last response",
							},
							stop = {
								modes = {
									n = "<localleader>q",
								},
								index = 5,
								callback = "keymaps.stop",
								description = "Stop Request",
							},
							clear = {
								modes = {
									n = "<localleader>x",
								},
								index = 6,
								callback = "keymaps.clear",
								description = "Clear Chat",
							},
							codeblock = {
								modes = {
									n = "<localleader>c",
								},
								index = 7,
								callback = "keymaps.codeblock",
								description = "Insert Codeblock",
							},
							yank_code = {
								modes = {
									n = "<localleader>y",
								},
								index = 8,
								callback = "keymaps.yank_code",
								description = "Yank Code",
							},
							pin = {
								modes = {
									n = "<localleader>p",
								},
								index = 9,
								callback = "keymaps.pin_context",
								description = "Pin Context",
							},
							watch = {
								modes = {
									n = "<localleader>w",
								},
								index = 10,
								callback = "keymaps.toggle_watch",
								description = "Watch Buffer",
							},
							change_adapter = {
								modes = {
									n = "<localleader>a",
								},
								index = 15,
								callback = "keymaps.change_adapter",
								description = "Change adapter",
							},
							fold_code = {
								modes = {
									n = "<localleader>f",
								},
								index = 15,
								callback = "keymaps.fold_code",
								description = "Fold code",
							},
							debug = {
								modes = {
									n = "<localleader>d",
								},
								index = 16,
								callback = "keymaps.debug",
								description = "View debug info",
							},
							system_prompt = {
								modes = {
									n = "<localleader>s",
								},
								index = 17,
								callback = "keymaps.toggle_system_prompt",
								description = "Toggle the system prompt",
							},
							auto_tool_mode = {
								modes = {
									n = "<localleader>ta",
								},
								index = 18,
								callback = "keymaps.auto_tool_mode",
								description = "Toggle automatic tool mode",
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
					opts = {
						show_defaults = false,
					},
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
					gemini_hard = function()
						return require("codecompanion.adapters").extend(
							"gemini",
							{
								name = "gemini_hard",
								schema = {
									reasoning_effort = {
										default = "high",
									},
								},
								env = {
									api_key = "cmd: cat $HOME/.config/sops-nix/secrets/GEMINI_API_KEY",
								},
							}
						)
					end,
				},
				extensions = {
					history = {
						enabled = true,
						opts = {
							-- Keymap to open history from chat buffer (default: gh)
							keymap = "gh",
							-- Save all chats by default (disable to save only manually using 'sc')
							auto_save = true,
							-- Number of days after which chats are automatically deleted (0 to disable)
							expiration_days = 0,
							-- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
							picker = "fzf-lua",
							---Automatically generate titles for new chats
							auto_generate_title = true,
							title_generation_opts = {
								---Adapter for generating titles (defaults to active chat's adapter)
								adapter = nil, -- e.g "copilot"
								---Model for generating titles (defaults to active chat's model)
								model = nil, -- e.g "gpt-4o"
							},
							---On exiting and entering neovim, loads the last chat on opening chat
							continue_last_chat = false,
							---When chat is cleared with `gx` delete the chat from history
							delete_on_clearing_chat = false,
							---Directory path to save the chats
							dir_to_save = vim.fn.stdpath("data")
								.. "/codecompanion-history",
							---Enable detailed logging for history extension
							enable_logging = false,
						},
					},
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							show_result_in_chat = true, -- Show mcp tool results in chat
							make_vars = true, -- Convert resources to #variables
							make_slash_commands = true, -- Add prompts as /slash commands
						},
					},
				},
			})
		end,
	},
}
