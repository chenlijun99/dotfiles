local M = {}

function M.tokenize_command(text)
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local result = {}
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. " " .. str, nil, nil
		elseif buf then
			buf = buf .. " " .. str
		end
		if not buf then
			local token = str:gsub(spat, ""):gsub(epat, "")
			table.insert(result, token)
		end
	end
	if buf then
		print("Missing matching quote for " .. buf)
	else
		return result
	end
end

function M.start_debug()
	local dap = require("dap")
	if vim.bo.filetype == "cpp" or vim.bo.filetype == "c" then
		local input = vim.fn.input(
			"Executable invocation: ",
			vim.fn.getcwd() .. "/",
			"shellcmd"
		)
		local tokens = M.tokenize_command(input)
		local program = tokens[1]
		table.remove(tokens, 1)
		local args = tokens

		local config = {
			name = "Launch",
			type = "lldb",
			request = "launch",
			program = program,
			args = args,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,

			-- 💀
			-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
			--
			--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
			--
			-- Otherwise you might get the following error:
			--
			--    Error on launch: Failed to attach to the target process
			--
			-- But you should be aware of the implications:
			-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
			runInTerminal = false,
			-- 💀
			-- If you use `runInTerminal = true` and resize the terminal window,
			-- lldb-vscode will receive a `SIGWINCH` signal which can cause problems
			-- To avoid that uncomment the following option
			-- See https://github.com/mfussenegger/nvim-dap/issues/236#issuecomment-1066306073
			-- postRunCommands = {
			     --"process handle -p true -s false -n false SIGWINCH",
			-- },
		}

		dap.run(config)
	else
		dap.continue()
	end
end

return M
