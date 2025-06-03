return {
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"<leader>am",
				"<cmd>MCPHub<cr>",
				mode = { "n", "v" },
				desc = "MCPHub",
			},
		},
		-- Bundles `mcp-hub` binary along with the neovim plugin
		-- See https://ravitemer.github.io/mcphub.nvim/installation.html
		build = "bundled_build.lua",
		config = function()
			require("mcphub").setup({
				-- Use local `mcp-hub` binary
				use_bundled_binary = true,
			})
		end,
	},
}
