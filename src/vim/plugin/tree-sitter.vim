if has('nvim-0.5.0')
lua <<EOF
require'nvim-treesitter.configs'.setup {
	ensure_installed = "maintained",
	highlight = {
		enable = false,
		disable = { "vim" },  
	},
}
EOF
end
