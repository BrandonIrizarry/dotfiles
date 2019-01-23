--[[
	README

	A module for opening files in Textadept, that uses a filtered
	list box that uses the output
of an 'ls' command.
	The button "Create" prompts to create a new file in the currently
	listed directory;
the "Descend" button will either list a subdirectory, or open a file
(depending on what the entry is.) Of course, also typing "Enter" on a
selected entry will _descend_ into that entry.
	Press "Esc" to cancel the box.

	Quick review of the ls flags used here:

	-L
		Dereference symbolic links;
	-a
		Show hidden files;
	-p
		Print directories with a final '/' (frontslash).
]]

local M = {} 

function M.open_file_or_new (dir)
	local curdir = buffer.filename and 
						buffer.filename:match("^.*/") or 
						string.format("%s/", os.getenv("HOME"))
						
	local dir = dir or curdir

	local gen_input = io.popen(string.format("ls -Lap %s", dir))
	local dir_entries = {}
	
	for entry in gen_input:lines() do
		dir_entries[#dir_entries + 1] = entry
	end

	local button_label, dir_entry = ui.dialogs.filteredlist {
		button1 = "Descend",
		button2 = "Create",
		title = "Open File or New", 
		columns = {dir},
		string_output = true,
		items = dir_entries
	}
	
	-- Prompt the user for the base filename.
	local function create ()
		local button, filename = ui.dialogs.standard_inputbox {
			title = "Create New File",
			informative_text = "New file:",
		}
		
		if button == 1 then
			buffer:new() -- make a new buffer, and switch focus to it.
			io.save_file_as(dir .. filename) -- write the buffer to disk with the given absolute filename.
		end
	end

	-- Note that "Esc" cancels the dialog box.
	if button_label == "Descend" then 
		if not dir_entry then -- user input was not among the possible selections.
			alert(nil, "That file or directory doesn't exist.")
			M.open_file_or_new(dir)
		elseif dir_entry == "./" then -- cheat code for file creation.
			create() 
		elseif dir_entry == "../" then -- find the parent directory: "$PARENT/optional_leaf_entry".
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
	elseif button_label == "Create" then
		create()
	end
end

return M