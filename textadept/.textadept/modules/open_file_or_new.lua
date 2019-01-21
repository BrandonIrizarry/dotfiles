--[[
	README
	
	A module for opening files in Textadept, that uses a filtered list box that uses the output 
of an 'ls' command. 
	The button "Create" prompts to create a new file in the currently listed directory;
the "Descend" button will either list a subdirectory, or open a file (depending on what
the entry is.) Of course, also typing "Enter" on a selected entry will _descend_ into that entry.
	Press "Esc" to cancel the box.
	
	Quick review of the ls flags used here:
	
	-L
		Dereference symbolic links;
	-a
		Show hidden files;
	-p  
		Print directories with a final '/' (frontslash).
	
	By far, L and p are the most important flags; an entry is a directory if and only if -p gives it
a final '/', so we can uniquely identify directories using this technique. Furthermore, L will dereference
symbolic links; otherwise, it won't be able to tell apart a _symlink to a directory_ from a non-directory.
Finally, -a gives us in addition all files that begin with a dot: this gives us access to "../", which allows
us to move up a directory; and the box's filtering functionality eases the burden of wading through a ton
of hidden files, making a full directory listing worth it.

	Admittedly, the only real extra benefit this module provides is fuzzy search. I mistakenly thought that
the default file opener in Textadept didn't let you create a new file, but that isn't true!
]]

local M = {} 

function M.open_file_or_new (dir)
	local buffer_curdir = buffer.filename:match("^.*/")
	local dir = dir or buffer_curdir
	

	-- Our function only knows something is a directory because of a final '/' in its name.
	local gen_input = io.popen(string.format("ls -Lap %s", dir))
	local dir_entries = {}
	
	gen_input:read() -- throw out "./" (the reference to the current directory.)
	
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
	--	elseif dir_entry == "./" then -- if we want, file creation can be buttonless.
	--		create() 
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
	elseif button_label == "Create" then
		create()
	end
end

return M