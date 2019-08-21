return function (name, bindings)
	
	-- The 'esc' binding exits the mode.
	bindings.esc = function ()
			ui.statusbar_text = string.format("Left '%s'", name)
			keys.MODE = nil -- exit the mode.
	end
	
		
	-- Technically, this is all you need to block excluded keypresses,
	-- but we need _some_ non-present keypresses to pass to a metatable;
	--[[
	events.connect(events.KEYPRESS, function ()
		if keys.MODE == name then
			return true -- Don't allow keypresses other than the mode's.
		end
	end)
	]]
	
	-- This lets us keep human-readable names for the keypresses.
	--setmetatable(keys[name], exclude)
	
	-- Give 'keys[name]' metatable privileges from 'bindings'.
	keys[name] = bindings 
	bindings = nil
	
	
	-- Return the function that activates the mode (so the caller can bind it to a key).
	return function ()
		ui.statusbar_text = string.format("'%s' mode, hit 'esc' to exit", name)
		keys.MODE = name
	end
end
