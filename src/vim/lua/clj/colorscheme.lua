local uv = vim.loop

local colorscheme_file_dir = vim.fn.stdpath("data") .. "/clj"
local colorscheme_file = colorscheme_file_dir .. "/colorscheme.vim"

local function file_exists(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "file"
end

local function source_colorscheme_file_if_exists()
	if file_exists(colorscheme_file) then
		vim.cmd("source " .. colorscheme_file)
	end
end

local function on_file_changed()
	vim.defer_fn(function()
		source_colorscheme_file_if_exists()
	end, 0)
end

local function generate_set_background_vimscript(desired_theme)
	return ("if &background != '" .. desired_theme .. "'\n")
		.. ("set background=" .. desired_theme .. "\n")
		.. "endif"
end

-- Define the function to start monitoring the file
local function start_monitoring_file()
	source_colorscheme_file_if_exists()

	if not file_exists(colorscheme_file) then
		local success, err = uv.fs_mkdir(colorscheme_file_dir, 511)
		if not success then
			print(
				"Failed to create directory ",
				colorscheme_file_dir,
				": ",
				err
			)
		end

		local file, err = io.open(colorscheme_file, "w")
		if not file then
			print("Failed to open file:", err)
		else
			-- Default to dark
			local success, err =
				file:write(generate_set_background_vimscript("dark"))
			if not success then
				print("Failed to write to file:", err)
			end
			file:close()
		end
	end

	local fs_event = uv.new_fs_event()
	fs_event:start(
		colorscheme_file,
		{ watch_entry = true },
		function(err, filename)
			if err then
				print("Error monitoring file:", err)
			else
				on_file_changed()
			end
		end
	)
end

-- Start monitoring the file when the plugin is loaded
start_monitoring_file()
