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

local patterns = {

	-- Examples:
	-- /home/brandon/ => match
	-- /home/brandon/myfile.txt => no match
	ANY_DIR = "/$",
	
	-- Examples: 
	-- /home/brandon/.textadept/ => /.textadept/
	-- / => /
	FINAL_DIR = "/[^/]*/?$",
	
	-- Examples:
	-- /home/brandon/.textadept/init.lua => /home/brandon/.textadept/
	PARENT_DIR = "^.*/",
}

function M.open_file_or_new (dir)
			
	-- Get all the directory entries.
	local curdir = buffer.filename and 
						buffer.filename:match(patterns.PARENT_DIR) or 
						string.format("%s/", os.getenv("HOME"))
						
	local dir = dir or curdir

	-- Used to prompt the user for the name of a new file.
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

	local gen_input = io.popen(string.format("ls -Lap %s", dir))
	local dir_entries = {}
	
	for line in gen_input:lines() do
		dir_entries[#dir_entries + 1] = line
	end


	-- Generate and present the filtered list to the user.
	local button_label, user_selections = ui.dialogs.filteredlist {
		button1 = "Descend",
		button2 = "Create",
		title = "Open File or New", 
		columns = {dir},
		string_output = true,
		select_multiple = true,
		items = dir_entries
	}
	
	-- Note that "Esc" cancels the dialog box.
	if button_label == "Descend" then 
		if #user_selections == 0 then -- user input was not among the possible selections.
			alert(nil, "That file or directory doesn't exist.")
			M.open_file_or_new(dir)
		else
			--Open all non-directories first.
			for i, sel in ipairs(user_selections) do
				if not sel:match(patterns.ANY_DIR) then -- matches a non-directory.
					io.open_file(dir .. sel)
					user_selections[i] = nil -- delete the entry to simplify the next for-loop.
				end
			end
		
			-- Now travel through all directories.
			for _, d in pairs(user_selections) do
				if d == "./" then 
					create()
				elseif d == "../" then
					local parent_dir = dir:sub(1, dir:find(patterns.FINAL_DIR)) -- grab until where that entry starts.
					M.open_file_or_new(parent_dir)
				else
					M.open_file_or_new(dir .. d)
        end
			end
    end
	elseif button_label == "Create" then
		create()
	end
end

return M