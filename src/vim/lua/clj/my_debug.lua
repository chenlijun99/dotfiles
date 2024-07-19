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
			type = "gdb",
			request = "launch",
			program = program,
			args = args,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
		}

		dap.run(config)
	else
		dap.continue()
	end
end

return M
