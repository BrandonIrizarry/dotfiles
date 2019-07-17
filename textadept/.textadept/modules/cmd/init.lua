local cmd = {}

local function load_submodules (filename)
    local sm = filename:match("^.*/([^.]+)") -- match the file's name, without the extension.
	cmd[sm] = require("cmd." .. sm) -- load that module into 'cmd'.
end

lfs.dir_foreach(_USERHOME .. "/modules/cmd/", load_submodules, {".lua", "!init.lua"}, 0)

return cmd

-- There can be multiple prefixes: to avoid code duplication, 
-- use a function that returns an appropriate function.
--[[
local function command_prefix (prefix)
	return function ()
		ui.command_entry:set_text(prefix)
		ui.command_entry.enter_mode("lua_command", "lua")
		
		-- The current buffer is the command entry itself.
		local orig_buffer = _G.buffer
		_G.buffer = ui.command_entry
		
		-- Unselect the selection, and move to the end of the command prompt.
		buffer:set_empty_selection(buffer.length) 
		
		-- Restore the current buffer to be the one being edited.
		_G.buffer = orig_buffer
	end
end
--]]


