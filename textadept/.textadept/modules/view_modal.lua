local mt = {__index = function (_, key)
	ui.statusbar_text = string.format("Key isn't bound in this mode: %s", key)
	return true
end}


keys.view_mode = {
	esc = function ()
		ui.statusbar_text = "Left View Mode"
		keys.MODE = nil -- exit the mode.
	end,
}

-- Default to using existing cmv bindings.
for bind, fn in pairs(keys.cmv) do
	if bind ~= "z" then
		keys.view_mode[bind] = fn
	end
end


keys.view_mode.v = keys.cmv.n -- cycle through views.
keys.view_mode.n = keys.mn -- next buffer.
keys.view_mode.p = keys.mp -- previous buffer.
keys.view_mode.b = keys.mb -- list open buffers

setmetatable(keys.view_mode, mt)

keys.cmv.z = function ()
	ui.statusbar_text = "View Mode, hit 'esc' to exit"
	keys.MODE = "view_mode"
end

events.connect(events.KEYPRESS, function (c)
	if keys.MODE == "view_mode" then
		return true -- Don't allow keypresses other than the mode's.
	end
end)
