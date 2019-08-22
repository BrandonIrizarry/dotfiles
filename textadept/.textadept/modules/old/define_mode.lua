--[[
	NB: From working on nprefix, I discovered how to block non-bound keys,
even pesky "Scintilla" ones - you simply bind the non-bound key to a 
dummy function that, say, outputs a message and returns true (see the
'setmetatable' call below.)
	tbc - we can't yet apply the metatable approach to blocking non-bound keys for 
define_mode modes, because nprefix.init modes are blank by design, and so upon being 
cast into a define_mode mode, it obtains the exclusion metatable, which we don't want.
	We may have to (gasp) reverse the order in which these are applied, or else somehow
combine them in one step.
]]

return function (name, bindings)
	
	-- The 'esc' binding exits the mode.
	bindings.esc = function ()
			ui.statusbar_text = string.format("Left '%s'", name)
			keys.MODE = nil -- exit the mode.
	end
	
	-- The secret for blocking non-bound keys...
	--setmetatable(bindings, {__index = function (t, key)
		--t[key] = function ()
			--ui.statusbar_text = string.format("'%s' not found in '%s'", key, name)
			--return true
		--end
		--
		--return t[key]
	--end})
	
	keys[name] = bindings 
	bindings = nil -- for garbage collection.
	
	
	-- Return the function that activates the mode (so the caller can bind it to a key).
	return function ()
		ui.statusbar_text = string.format("'%s' mode, hit 'esc' to exit", name)
		keys.MODE = name
	end
end
