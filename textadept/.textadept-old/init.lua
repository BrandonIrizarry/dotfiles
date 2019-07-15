-- Avoid suspending curses version (undo instead)
events.connect(events.SUSPEND, function()
	buffer:undo()
	return true
end, 1)

require "theming" 

_C = {} -- natural-language commands
function _C.terminal ()
	os.spawn("xterm", buffer.filename:match(".*/") or os.getenv("HOME"))
end

_C.run = textadept.run.run

function _C.config () 
	io.quick_open(_USERHOME)
end

function _C.root_config ()
	io.quick_open(_HOME)
end

_C.doc = textadept.editing.show_documentation

function _C.only ()
	while view:unsplit() do end
end

function _C.reset ()
	-- Only save if there are unsaved changes (that is, we may care to first
	-- "save by hand", because we know we're resetting, and we have that habit.)
	if buffer.modify then
		io.save_file() -- presumably 'init.lua', or else the config file you're editing.
	end
	
	reset()
end

--_G.reset = nil -- no more Textadept reset!

_C.quit = quit -- throw this in as a command
--_G.quit = nil -- no more quit!

-- Needs to be wrapped in a function call, 
-- to avoid writing to a message buffer.
function _C.close ()
	io.close_buffer()
end

function _C.close_all ()
	io.close_all_buffers()
end

_C.buffers = ui.switch_buffer

-- To use the command prompt, just erase the "_C." :)
function keys.mc ()
	ui.command_entry:set_text("_C.")
	ui.command_entry.enter_mode("lua_command", "lua")
	
	-- The current buffer is always the one being edited; 
	-- so we have to explicitly tell Textadept that the
	-- the current buffer is actually the command entry.
	local orig_buffer = _G.buffer
	_G.buffer = ui.command_entry
	
	-- Unselect the selection, and move to the end of the command prompt.
	buffer:set_empty_selection(buffer.length) 
	
	-- Restore the current buffer to be the one being edited.
	_G.buffer = orig_buffer
end


-- Clobber pasting
function keys.cv ()
	buffer:page_down()
end

-- OK, since C-z is undo now.
function keys.mv ()
	buffer:page_up()
end

-- Replace pasting
-- Use 'mZ' for redo.
function keys.cy ()
	buffer:paste()
end

-- Clobber homedir quick open
-- Homedir quick open is now a command.
function keys.cu ()
	buffer:del_line_left()
end

-- C-k is the new 'cut'.
local kill_line = keys.ck -- we'll use ck's original functionality to define the new function
function keys.ck ()
	if (buffer:get_sel_text()) == "" then
		kill_line()
	else
		buffer:cut()
	end
end

-- Clobber 'buffer:close()'
-- Now a command.
keys.cw = keys.cmv

function _C.alert (...)
    local args = table.pack(...)
    
    for i=1, args.n do
      args[i] = tostring(args[i])
    end
    
    local data = table.concat(args, "\n")
    
    ui.dialogs.msgbox {
      title = "Alert!",
      text = data,
    }
end



local result = pcall(require, "jump")

if not result then
	_C.alert("Error: will not load module 'jump'")
end


function _C.bookmark ()
	textadept.bookmarks.toggle()
end

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	_C.alert(string.format("Wrote file '%s' to disk!", basename))
end)