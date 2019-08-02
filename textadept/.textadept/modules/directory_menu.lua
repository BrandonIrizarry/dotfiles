local M = {}

local function strip (entry)
	local pos = entry:find("[*/=>@|]")
	if pos then 
		return entry:sub(1, pos - 1), entry:sub(pos, pos)
	else
		return entry
	end
end

local function dir_set (path)
	local set = {}
	
	local ls_handle = io.popen("ls -aLF "..path)
	
	for entry in ls_handle:lines() do
		local base, suffix = strip(entry)
		
		if suffix == "/" then
			set[entry] = function ()
				launch_menu(dir_set(path..entry))
			end
		else
			set[base] = function () io.open_file(path..base) end
		end
	end
	
	return set
end

local function print_set (set)
	for key, value in pairs(set) do
		print(key, value)
	end
end

function M.init ()
	launch_menu(dir_set("/home/brandon/"))
end

return M