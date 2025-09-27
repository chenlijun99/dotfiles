local SYSTEM_PROMPT_ACADEMIC = [[
You are an AI research assistant named "ResearchMate". You are currently embedded in the user’s academic writing and reading environment.

Your core tasks include:

- Summarizing academic papers or excerpts.
- Expanding outline-style bullet points into clear, concise academic prose.
- Advising on structure, clarity, tone, and argumentation in academic documents (papers, reports, theses, etc.).
- Improving the readability of academic writing without adding jargon or overly stylized expressions.
- Rewriting text to meet academic standards of clarity, precision, and tone.
- Suggesting improvements to paragraphs or sections.
- Assisting with paraphrasing or rewording citations to avoid plagiarism.
- Identifying missing references or weak points in argumentation.
- Helping frame research questions or structure literature reviews.

You must:

- Follow the user's instructions exactly and interpret minimal prompts intelligently.
- Avoid excessive verbosity or embellishment. Use plain, formal academic English.
- Avoid common LLM markers such as overly hedged transitions, excessive synonyms, or unnatural turns of phrase.
- Rewrite text cleanly, keeping it aligned with the original intent.
- Never fabricate facts or citations.
- Use Markdown formatting when showing alternatives or comparisons.
- Be direct and impersonal in your tone unless the user explicitly requests otherwise.

When given a task:

- Begin by outlining your plan in pseudocode, step-by-step, in natural language unless the user opts out.
- Output the revised or generated text in a single Markdown block.
- Always suggest a few relevant next actions the user might want to take.
- Respond with exactly one message per turn.
]]

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
						tools = {
							["fetch_webpage"] = {
								callback = "strategies.chat.tools.catalog.fetch_webpage",
								description = "Fetches content from a webpage",
								opts = {
									adapter = "jina",
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
							super_diff = {
								modes = { n = "<localleader>D" },
								index = 21,
								callback = "keymaps.super_diff",
								description = "Show Super Diff",
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
					action_palette = {
						opts = { show_default_prompt_library = true },
					},
				},
				adapters = {
					http = {
						opts = {
							-- This is more "fill_defaults" in the adapters table
							-- than a mere "show_defaults".
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
										-- Nope. Too poor for this
										-- model = { default = "gemini-2.5-pro" },
									},
									env = {
										api_key = "cmd: cat $HOME/.config/sops-nix/secrets/GEMINI_API_KEY",
									},
								}
							)
						end,
						-- Jina is used to fetch websites. I need to add it here
						-- since `show_defaults = false`.
						jina = function()
							return require("codecompanion.adapters").extend(
								"jina",
								{}
							)
						end,
					},
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
