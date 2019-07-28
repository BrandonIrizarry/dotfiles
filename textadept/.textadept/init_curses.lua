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
	"alert",
	"select_lines",
	"term",
	"copy_paste",
	"config",
	"view_modal",
	--"sfn",
	--"map",
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
			report = string.format("Name '%s' already taken.\nAborting config.", mod)
			break
		end
			
		_G[mod] = result
	end
	
	local NOTIFY_STATUS = report and ui.print or alert
	NOTIFY_STATUS(report or "Success.")
end)