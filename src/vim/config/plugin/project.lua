-- This plugin helps me to set project specific configurations,
-- while not putting executable config files within the project
Plug("windwp/nvim-projectconfig", {
	config = function()
		-- Schedule it to run later in the main loop, so that project-specific
		-- configurations are applied later and effectively override the global
		-- configuration
		vim.schedule(function()
			require("nvim-projectconfig").setup({
				-- projects-config directory
				project_dir = "~/.vim/projects/",
				-- load project config when I change my directory inside neovim
				autocmd = true,
				-- display message after load config file
				silent = false,
			})
		end)
	end,
})
