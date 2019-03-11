Plug 'vim-vdebug/vdebug', {
			\ 'for': 'php'
			\}

if !exists('g:vdebug_options')
	let g:vdebug_options = {}
endif
let g:vdebug_options.ide_key = "vim_xdebug"

let g:vdebug_keymap = {
			\    "run" : "<F5>",
			\    "run_to_cursor" : "<F6>",
			\    "step_over" : "<F10>",
			\    "step_into" : "<F12>",
			\    "step_out" : "<S-F12>",
			\    "close" : "<F7>",
			\    "detach" : "<F8>",
			\    "set_breakpoint" : "<F9>",
			\    "get_context" : "<F2>",
			\    "eval_under_cursor" : "<Leader>E",
			\    "eval_visual" : "<Leader>e"
			\}
