vim.cmd([[
let g:which_key_map.d = { 'name' : '+debug' }
]])

Plug("mfussenegger/nvim-dap", {
	config = function()
		local dap = require("dap")

		vim.cmd([[
			let g:which_key_map.d.s = 'Start debugging/continue'
			nnoremap <silent> <leader>ds :lua require'my_debug'.start_debug()<CR>

			let g:which_key_map.d.S = 'Debug with last config'
			nnoremap <silent> <leader>dS :lua require'dap'.run_last()<CR>

			let g:which_key_map.d.c = 'Continue'
			nnoremap <silent> <leader>dc :lua require'dap'.continue()<CR>

			let g:which_key_map.d.x = 'Terminate'
			nnoremap <silent> <leader>dx :lua require'dap'.terminate()<CR>

			let g:which_key_map.d.u = 'Run until cursor'
			nnoremap <silent> <leader>du :lua require'dap'.run_to_cursor()<CR>

			let g:which_key_map.d.n = 'Step over'
			nnoremap <silent> <leader>dn :lua require'dap'.step_over()<CR>

			let g:which_key_map.d.i = 'Step into'
			nnoremap <silent> <leader>di :lua require'dap'.step_into()<CR>

			let g:which_key_map.d.o = 'Step out'
			nnoremap <silent> <leader>do :lua require'dap'.step_out()<CR>

			let g:which_key_map.d.b = 'Toggle breakpoint'
			nnoremap <silent> <leader>db :lua require'dap'.toggle_breakpoint()<CR>

			let g:which_key_map.d.B = 'Set conditional breakpoint'
			nnoremap <silent> <leader>dB :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>

			let g:which_key_map.d.l = 'Set log point'
			nnoremap <silent> <leader>dl :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>

			let g:which_key_map.d.r = 'Open REPL'
			nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
		]])

		-- Customize signs
		vim.fn.sign_define(
			"DapBreakpoint",
			{ text = "🛑", texthl = "", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "🟡", texthl = "", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapLogPoint",
			{ text = "🔵", texthl = "", linehl = "", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "❌", texthl = "", linehl = "", numhl = "" }
		)

		-- Got from https://stackoverflow.com/a/28664691
		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/bin/lldb-vscode", -- adjust as needed
			name = "lldb",
		}

		-- If you want to use this for rust and c, add something like this:
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp
	end,
})
Plug("rcarriga/nvim-dap-ui", {
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		-- Copied from https://gist.github.com/balaam/3122129?permalink_comment_id=1680319#gistcomment-1680319
		local function reverse(tbl)
			for i = 1, math.floor(#tbl / 2) do
				local tmp = tbl[i]
				tbl[i] = tbl[#tbl - i + 1]
				tbl[#tbl - i + 1] = tmp
			end
			return tbl
		end

		dapui.setup({
			mappings = {
				-- I like this mappings.
				-- Theoretically, there is no window of nvim-dap-ui where
				-- "open" and "expand" are both available. So we don't risk
				-- overlap of mapping.
				-- But actually the expand and open command mappings are
				-- defined for all the nvim-dap windows, regardless of whether
				-- the command makes sense in a window.
				-- So I guess I have to use the default mappings.
				-- expand = { "<CR>", "o", "<2-LeftMouse>" },
				-- open = { "<CR>", "o", "<2-LeftMouse>" },
			},
			sidebar = {
				-- The order of the windows in the screen is actually the
				-- opposite of one they are listed here. That why we use reverse.
				elements = reverse({
					{ id = "stacks", size = 0.25 },
					-- Put "scopes" window (the most used one) in the center
					{
						id = "scopes",
						size = 0.35,
					},
					{ id = "breakpoints", size = 0.25 },
					{ id = "watches", size = 0.15 },
				}),
				size = 50,
				-- Left already occupied by file tree
				position = "right",
			},
		})

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		-- Don't close on exit or termination.
		-- Often a "one-shot" program without breakpoints exists immediately.
		-- I want to see the output of the program.
		--dap.listeners.before.event_terminated["dapui_config"] = function()
		--dapui.close()
		--end
		--dap.listeners.before.event_exited["dapui_config"] = function()
		--dapui.close()
		--end

		vim.cmd([[
			let g:which_key_map.d.e = 'Eval'
			nnoremap <silent> <leader>de <Cmd>lua require("dapui").eval(vim.fn.input("Executable invocation: "))<CR>
			vnoremap <silent> <leader>de <Cmd>lua require("dapui").eval()<CR>
		]])

		which_key_map.p = {
			d = "Open debug ui",
		}
		local opts = { noremap = true, silent = true }
		vim.api.nvim_set_keymap(
			"n",
			"<leader>pd",
			"<cmd>lua require'dapui'.open()<CR>",
			opts
		)

		which_key_map.p = {
			D = "Close debug ui",
		}
		vim.api.nvim_set_keymap(
			"n",
			"<leader>pD",
			"<cmd>lua require'dapui'.close()<CR>",
			opts
		)
	end,
})
