local past_commands = {} -- use as a set to avoid duplicate entries.

-- Rebind the Enter key to first save the command, then launch it.
-- Explicitly rebind Tab as well, to prevent TA from saving commands
-- after the user hits Tab.
local old_ret = keys.lua_command["\n"] 
local old_tab = keys.lua_command["\t"]

keys.lua_command = {
	["\n"] = 
		function ()
			past_commands[ui.command_entry:get_text()] = true
			return old_ret() 
		end,
	["\t"] = old_tab 
}

-- Save 'past_commands' after successive resets!
events.connect(events.RESET_BEFORE, function (t)
	t.past_commands = past_commands
end)

events.connect(events.RESET_AFTER, function (t)
	past_commands = t.past_commands
end)

local function select_command ()
	local itemized = {}
	
	for cmd in pairs(past_commands) do
		itemized[#itemized + 1] = cmd
	end
	
	local options = {
		title = "Previous Commands",
		columns = {"Which one?"},
		string_output = true,
		items = itemized,
		button2 = "Clear",
	}
	
	local button, choice = ui.dialogs.filteredlist(options)
	if button == "OK" then
		ui.command_entry:set_text(choice)
		ui.command_entry.finish_mode(function() old_ret() end)
	elseif button == "Clear" then
		past_commands = {}
	end
end

-- Global key bindings.
keys.mu = select_command

return select_command