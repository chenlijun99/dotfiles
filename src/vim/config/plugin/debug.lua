vim.cmd([[
let g:which_key_map.d = { 'name' : '+debug' }
]])

local dapui = {
	"rcarriga/nvim-dap-ui",
	lazy = true,
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
			layouts = {
				{
					-- The order of the windows in the screen is actually the
					-- opposite of one they are listed here. That why we use reverse.
					elements = reverse({
						{ id = "stacks",      size = 0.25 },
						-- Put "scopes" window (the most used one) in the center
						{
							id = "scopes",
							size = 0.35,
						},
						{ id = "breakpoints", size = 0.25 },
						{ id = "watches",     size = 0.15 },
					}),
					size = 50,
					position = "right",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 10,
					position = "bottom",
				},
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
}

return {
	dapui,
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			dapui,
		},
		keys = {
			{
				"<leader>ds",
				"lua require'clj.my_debug'.start_debug()<CR>",
				desc = "Start debugging/continue",
			},
			{
				"<leader>dS",
				"lua require'dap'.run_last()<CR>",
				desc = "Debug with last config",
			},
			{
				"<leader>dc",
				"lua require'dap'.continue()<CR>",
				desc = "Continue",
			},
			{
				"<leader>dx",
				"lua require'dap'.terminate()<CR>",
				desc = "Terminate",
			},
			{
				"<leader>du",
				"lua require'dap'.run_to_cursor()<CR>",
				desc = "Run until cursor",
			},
			{
				"<leader>dn",
				"lua require'dap'.step_over()<CR>",
				desc = "Step over",
			},
			{
				"<leader>di",
				"lua require'dap'.step_into()<CR>",
				desc = "Step into",
			},
			{
				"<leader>do",
				"lua require'dap'.step_out()<CR>",
				desc = "Step out",
			},
			{
				"<leader>db",
				"lua require'dap'.toggle_breakpoint()<CR>",
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dB",
				"lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
				desc = "Set conditional breakpoint",
			},
			{
				"<leader>dl",
				"lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
				desc = "Set log point",
			},
			{
				"<leader>dr",
				"lua require'dap'.repl.open()<CR>",
				desc = "Open REPL",
			},
		},
		config = function()
			local dap = require("dap")

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
	},
}
