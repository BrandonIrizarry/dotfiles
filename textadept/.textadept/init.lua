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
	"utils",
	"copy_paste",
	"config",
	"view_modal",
}

-- Theming has to be done before initialization is complete.
require "theme"

events.connect(events.INITIALIZED, function ()
	local report
	
	for _, mod in ipairs(modules) do
		local status, result = pcall(require, mod)

		if not status then -- we all know what this means. :)
			report = string.format("Error in module '%s':\n%s\nAborting config.", mod, result)
			break
		end
		
		-- Check the availability of the module name, before making it global.
		if _G[mod] ~= nil then
			report = string.format("Name '%s' already taken.", mod)
			break
		end
			
		_G[mod] = result
	end
	
	local NOTIFY_STATUS = report and ui.print or utils.alert
	NOTIFY_STATUS(report or "Success.")
	
	local function say_hi ()
		ui.print("hi")
	end
	
	
	function naive_clone (fn)
		return load(string.dump(fn))
	end
	
	--[[
	for binding, fn in pairs(keys.KEYSYMS) do
		ui.print(binding, fn)
	end
--]]
	
	--naive_clone(function () ui.command_entry.enter_mode("lua_command", "lua") end)()
	
	---[[
	function get_upvalues (fn)
		local i = 1
		while true do
			local name = debug.getupvalue(fn, i)
			if not name then
				break
			end
			ui.print(name)
			i = i + 1
		end
	end
	--]]
	
	for binding, fn in pairs(keys) do
		if type(fn) == "function" then
			ui.print(binding)
			get_upvalues(fn)	
			ui.print(string.rep("-", 50))
		end
	end
	
		
end)