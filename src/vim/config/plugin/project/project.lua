-- This plugin helps me to set project specific configurations,
-- while not putting executable config files within the project
return {
	{
		"windwp/nvim-projectconfig",
		event = "VeryLazy",
		opts = {
			-- projects-config directory
			project_dir = "~/.vim/projects/",
			-- load project config when I change my directory inside neovim
			autocmd = true,
			-- display message after load config file
			silent = false,
		},
	},
}
