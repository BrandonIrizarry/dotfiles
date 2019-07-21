require "theme"

-- Pressing C-z will undo, instead.
events.connect(events.SUSPEND, function()
	buffer:undo()
	return true
end, 1)

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	ui.statusbar_text = string.format("Wrote file '%s' to disk!", basename)
end)

-- Fill in some missing 'view' keybindings.
keys.cmv.q = function ()
	ui.goto_view(1)
	view:unsplit()
end

local modules = {
	"theme",
	"copy_paste",
	"utils",
	"ringbuffer",
	"config",
	"view_modal",
}

Log = require("log"):new(_USERHOME .. "/log.txt")

for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)

	if not status then
		Log:log(result, false)
		goto end_of_config
	end
	
	if _G[mod] ~= nil then
		Log:log("Name '%s' already taken.", false, mod)
		goto end_of_config
	end
		
	_G[mod] = result
end

-- Confirm that all went well with loading user modules.
Log:log("Success.", true)

::end_of_config::
Log:finish()


past_commands = ringbuffer:new(10)

-- Save the original command-entry launcher hook.
local old_command = keys.lua_command["\n"] 

keys.lua_command["\n"] = function ()
	past_commands:push(ui.command_entry:get_text())
	return old_command() 
end


-- Save 'past_commands' after successive resets!
events.connect(events.RESET_BEFORE, function (t)
	t.past_commands = past_commands
end)

events.connect(events.RESET_AFTER, function (t)
	past_commands = t.past_commands
end)

function select_command ()
	local options = {
		title = "Previous Commands",
		columns = {"Which one?"},
		string_output = true,
		items = past_commands,
	}
	
	local button, choice = ui.dialogs.filteredlist(options)
	if button == "OK" then
		ui.command_entry:set_text(choice)
		ui.command_entry.finish_mode(function() old_command() end) -- telegraphic;
		-- but I see a module in my future, tbc.
		-- also, remove duplicates from past_commands.
		-- Dependencies... tbc.
	end
end
	