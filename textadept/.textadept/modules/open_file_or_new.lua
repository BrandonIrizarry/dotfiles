

local M = {} 

function M.open_file_or_new (dir)
	local buffer_curdir = buffer.filename:match("^.*/")
	local dir = dir or buffer_curdir
	
	-- ls flags (see 'man ls'):
	-- Dereference symbolic links with 'L';
	-- Show hidden files with 'a';
	-- Mark directories with a final '/' with 'p'.
	-- Our function only knows something is a directory because of a final '/' in its name.
	local gen_input = io.popen(string.format("ls -Lap %s", dir))
	local dir_entries = {}
	
	for entry in gen_input:lines() do
		dir_entries[#dir_entries + 1] = entry
	end

	
	local button_label, dir_entry = ui.dialogs.filteredlist {
		button1 = "Descend",
		title = "Open File or New", 
		columns = {dir},
		string_output = true,
		items = dir_entries
	}
	
	-- Prompt the user for the base filename.
	local function create ()
		local button, filename = ui.dialogs.standard_inputbox {
			title = "Create New File",
			informative_text = "Textadept will create a new file with this name.",
		}
		
		if button == 1 then
			buffer:new() -- make a new buffer, and switch focus to it.
			io.save_file_as(dir .. filename) -- write the buffer to disk with the given absolute filename.
		end
	end

	if button_label == "Descend" then -- e.g., user doesn't hit Escape to cancel.
		if not dir_entry then -- user input was not among the possible selections.
			alert(nil, "That file or directory doesn't exist")
			M.open_file_or_new(dir)
		elseif dir_entry == "./" then -- make file creation buttonless.
			create() 
		elseif dir_entry == "../" then
			local optional_leaf_entry  = "/[^/]*/?$" -- handles case where dir == "/".
			local parent_dir = dir:sub(1, dir:find(optional_leaf_entry)) -- grab until where that entry starts.
			M.open_file_or_new(parent_dir)
		else
			local entry_abspath = dir .. dir_entry -- otherwise, get the absolute path of the current selection.
		
			if dir_entry:find("/$") then -- the current selection is a directory.
				M.open_file_or_new(entry_abspath)
			else
				io.open_file(entry_abspath) -- we can open an existing, non-directory entry in Textadept.
			end
		end
	end
end

return M