--[[
	Some things done only in the main init file (i.e., not in a module):
	- setting the user's theme.
	- connecting to events.
	- setting keybindings.
	- all calls to 'ui.print'.
	- loading modules.
	
	Note that theming is done first, so that errors don't ruin it.
]]

-- THEME
local theme, font_table

if CURSES then
	theme = "term-bci"
else
	theme = "dark-bci"
	
	font_table = { 
		font = "Fira Mono", 
		fontsize = 15
	}
end

buffer:set_theme(theme, font_table)

-- Always use tabs of width 4 for indentation.
buffer.use_tabs = true
buffer.tab_width = 4

-- Disable indentation guides
buffer.indentation_guides = buffer.IV_NONE

-- Disable code folding and hide the fold margin
buffer.property.fold = "0" 
buffer.margin_width_n[2] = 0

-- Disable character autopairing with typeover
textadept.editing.auto_pairs = nil
textadept.editing.typeover_chars = nil


-- Pressing C-z will undo, instead.
events.connect(events.SUSPEND, function()
	buffer:undo()
	return true
end, 1)

-- Quick and dirty replacement for caps lock.
keys.cl = function ()
	textadept.editing.select_word()
	buffer:upper_case()
	buffer:set_empty_selection(buffer.current_pos)
end

-- LOAD MODULES.

local modules = {
	"copy_paste",
	"utils",
	--"commands",
    --"wtf", -- nonexistent module
	"cmd",
}

data = {}

	
for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)

	if status then
		data[mod] = result
	else
		data = result
		break
	end
end

events.connect(events.INITIALIZED, function ()
	if type(data) == "string" then
		ui.print(data)
		ui.print("Aborting config.")
		return -- abort the rest of the config
	end

	-- Confirm that all went well with loading user modules.
	data.utils.alert("Success!")
	
	-- Make 'cmd' global.
	cmd = data.cmd
	
	-- Confirm saves with a dialog box.
	events.connect(events.FILE_AFTER_SAVE, function (filename)
		local basename = filename:match("^.+/(.+)")
		data.utils.alert(string.format("Wrote file '%s' to disk!", basename))
	end)
	
	-- Copying.
	keys.cc = function ()
		local sel = buffer.get_sel_text()
		data.copy_paste.clipboard_write(sel)
	end

	-- Cutting.
	keys.cx = function ()
		local sel = buffer.get_sel_text()
		buffer:cut()
		data.copy_paste.clipboard_write(sel)
	end

	-- Pasting.
	keys.cv = function () 
		local text = data.copy_paste.clipboard_read() 
		buffer:add_text(text)
	end
end)










--[[
_C = data.commands

-- There can be multiple prefixes: to avoid code duplication, 
-- use a function that returns an appropriate function.
function command_prefix (prefix)
	return function ()
		ui.command_entry:set_text(prefix)
		ui.command_entry.enter_mode("lua_command", "lua")
		
		-- The current buffer is always the (big) one being edited; 
		-- so we have to explicitly tell Textadept that the
		-- the current buffer is the command entry itself.
		local orig_buffer = _G.buffer
		_G.buffer = ui.command_entry
		
		-- Unselect the selection, and move to the end of the command prompt.
		buffer:set_empty_selection(buffer.length) 
		
		-- Restore the current buffer to be the one being edited.
		_G.buffer = orig_buffer
	end
end

keys.mc = command_prefix("_C.")
--]]

--[===[
_C = protect_require("commands")
_V = protect_require("view")
_B = protect_require("buffer")

TYPES = {}
TYPES.message_buffer = "[Message Buffer]" -- avoid typos




-- Clobber homedir quick open
-- Homedir quick open is now a command.
function keys.cu ()
	buffer:del_line_left()
end


PAST_COMMANDS = {}

-- Save the original command-entry launcher hook.
do
	local old_command = keys.lua_command["\n"] 

	keys.lua_command["\n"] = function ()
		-- For some reason, 'table.insert' doesn't work here (limited environment?)
		PAST_COMMANDS[#PAST_COMMANDS + 1] = ui.command_entry:get_text()
		return old_command() 
	end
end

-- Save 'PAST_COMMANDS' after successive resets!
events.connect(events.RESET_BEFORE, function (t)
	t.past_commands = PAST_COMMANDS
end)

events.connect(events.RESET_AFTER, function (t)
	PAST_COMMANDS = t.past_commands
end)




keys.mv = command_prefix("_V.")
keys.mb = command_prefix("_B.")



--function run_past_command
--[[
local button, i = ui.dialogs.filteredlist {
	title = "Title", columns = {'Foo'},--columns = {'Foo          ', 'Bar'},
	items = {'a', 'b', 'c', 'd'}
}

if button == 1 then
	ui.print('Selected row ', i)
end
--]]
--]===]

