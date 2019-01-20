--[[ As steals the morn upon the night,
and melts the shades away,
so Truth does Fancy's charm dissolve,
and rising Reason puts to flight
the fumes that did the mind involve,
restoring intellectual day.

from L'Allegro, il Penseroso ed il Moderato
Charles Jennens and George Frideric Handel (1685-1759)
]]  

-- When calling this function, make sure the timeout in seconds is the first argument!
alert = require("alert").alert 

if not CURSES then
  rgb_dialog = require("rgb_dialog").dialog
end

function 	directory ()
    return buffer.filename:match("^(.-)[^/]*$")
end

-- Load extra snippets to the Lua snippets table; 
-- make sure that the Lua lexer is loaded _first_.
events.connect(events.LEXER_LOADED, function (lexer)
  if lexer == "lua" then
    for shorthand, snippet in pairs(require("es_lua")) do
      snippets.lua[shorthand] = snippet
    end
  end
end)

-- Load my personal global snippets into Textadept.
for shorthand, snippet in pairs(require("es_global")) do
  snippets[shorthand] = snippet
end

-- Load extra/personal keybindings into Textadept.
if not CURSES then
  for binding, func in pairs(require("extra_keys")) do
    keys[binding] = func
  end
end

-- Confirm saves with a dialog box.
events.connect(events.FILE_BEFORE_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	alert(1, string.format("Wrote file '%s' to disk!", basename))
end)

-- Before resetting, save all open buffers to disk.
events.connect(events.RESET_BEFORE, function ()
  io.save_all_files()
end)


if CURSES then
    buffer:set_theme("term")
else
	local FONT_TABLE = {font = "Inconsolata", fontsize = 15}
	local THEME = "dark"

	buffer:set_theme(THEME, FONT_TABLE)
end

keys.cT = function () os.spawn("desktop-defaults-run -t", buffer.filename:match("^(.*)/")) end

-- Disable character autopairing with typeover
textadept.editing.auto_pairs = nil
textadept.editing.typeover_chars = nil

-- Always use tabs of width 4 for indentation.
buffer.use_tabs = true
buffer.tab_width = 4

-- Disable indentation guides
buffer.indentation_guides = buffer.IV_NONE

-- Disable code folding and hide the fold margin
buffer.property.fold = "0"
buffer.margin_width_n[2] = 0

-- TO BE PUT IN A SEPARATE MODULE, AND BOUND TO A KEY.
-- Disallow ./ and ../, since they make no practical sense when they appear in absolute filenames.
-- We might want a button that says, "Up", tbc.
function open_or_create_file (dir)
	local dir = dir or os.getenv("HOME") .. "/"
	local dir_entries = {}
	local gen_input = io.popen(string.format("ls -Fa %s", dir))
	
	for entry in gen_input:lines() do
		if entry ~= "./" and entry ~= "../" then -- for now, disallow this - maybe add buttons that navigate.
			dir_entries[#dir_entries + 1] = entry
		end
	end

	
	local button_label, dir_entry = ui.dialogs.filteredlist {
		button1 = "Descend",
		button2 = "Create",
		title = "Open/New File", 
		columns = {string.format("Contents of %s", dir)},
		string_output = true,
		items = dir_entries
	}
	
	-- Create a new buffer with the desired name.
	local function create ()
		local button, filename = ui.dialogs.standard_inputbox {
			title = "Create New File",
			informative_text = "Textadept will create a new file with this name.",
			text = dir
		}
		
		if button == 1 then
			buffer:new() -- make a new buffer, and switch focus to it.
			io.save_file_as(filename) -- write the buffer to disk with the given absolute filename.
		end
	end

	if button_label == "Descend" then
		if not dir_entry then -- user input was not among the possible selections.
			create() -- hence, prompt the user to create and open a new file here.
		else
			local entry_abspath = dir .. dir_entry -- otherwise, get the absolute path of the current selection.
		
			if dir_entry:find("/$") then -- the current selection is a directory.
				example2(entry_abspath)
			else
				io.open_file(entry_abspath) -- we can open an existing, non-directory entry in Textadept.
			end
		end
	elseif button_label == "Create" then
		create()
	end
end