--[[
	FIXME:
	
	files, directories, don't use UNIX suffix when 'launch_menu' sorts 
its entries.

	1. Typing in a nonexistent file should offer to create and open that file
	in a buffer.
	
	2. Typing in a nonexistent directory should offer to create and take you
	into that directory.
	
	3. "./" should come before "../", and possibly other things; so we don't
	want the UNIX */=>@ filetype suffixes getting included in the sorting
	criteria. Possibly include an option in 'launch_menu' that would exclude
	certain characters, or a certain suffix of a string, I don't know yet, tbc.
]]


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