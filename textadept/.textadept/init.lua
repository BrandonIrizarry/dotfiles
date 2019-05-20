-- Avoid suspending curses version:
-- any attempt to suspend the curses version will, instead, undo.
events.connect(events.SUSPEND, function()
	buffer:undo()
	return true
end, 1)

require "theming" 



_C = {}

_C.terminal = function ()
	os.spawn("xterm", buffer.filename:match(".*/") or os.getenv("HOME"))
end

_C.run = textadept.run.run

_C.config = function () 
	io.quick_open(_USERHOME)
end

_C.root_config = function ()
	io.quick_open(_HOME)
end

_C.help = textadept.editing.show_documentation

_C.only = function ()
	while view:unsplit() do end
end

-- Needs to be wrapped in a function call, 
-- to avoid writing to a message buffer.
_C.close = function ()
	io.close_buffer()
end

keys.mx = function ()
	ui.command_entry:set_text("_C.")
	ui.command_entry.enter_mode("lua_command", "lua")
	
	local orig_buffer = _G.buffer
	_G.buffer = ui.command_entry
	buffer:set_empty_selection(buffer.length)
	_G.buffer = orig_buffer
end

-- Autocomplete a custom command in the command entry
--[[
local function autocomplete_command ()
	local commands = {}
	
	for cmd in pairs(_C) do
		table.insert(commands, cmd)
	end
	
	local part = ui.command_entry:get_text()
	local list = table.concat(commands, " ")
	
	ui.command_entry:auto_c_show(#part - 1, list)
end

local function do_command(text)
	_C[text]()
end

keys.custom_command = {
	["\t"] = autocomplete_command,
	["\n"] = function ()
		return ui.command_entry.finish_mode(do_command)
	end
}

keys.ml = function ()
	ui.command_entry.enter_mode("custom_command")
end
--]]




-- Clobber pasting
keys.cv = function ()
	buffer:page_down()
end

-- OK, since C-z is undo now.
keys.mv = function ()
	buffer:page_up()
end

-- Replace pasting
-- Use 'mZ' for redo.
keys.cy = function ()
	buffer:paste()
end

-- Clobber homedir quick open
-- Homedir quick open is now a command
keys.cu = function ()
	buffer:del_line_left()
end

-- C-k is the new 'cut'.
local kill_line = keys.ck
keys.ck = function ()
	if (buffer:get_sel_text()) == "" then
		kill_line()
	else
		buffer:cut()
	end
end

-- Clobber 'buffer:close()'
-- Now a command.
keys.cw = keys.cmv




