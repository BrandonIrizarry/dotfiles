events.connect(events.INITIALIZED, function ()
	textadept.menu.menubar = nil
end)

config = require "config"

-- alt can now be used to define key bindings
keys.ag = function () ui.print("HI") end
