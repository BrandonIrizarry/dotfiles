--[[ 
	NB: For bindings, if you return a function, it's executed; if you
return a table, it triggers a keychain.
	Also, to use local functions recursively, you need to first declare
the variable to be used for the function (in this case, 'idx_meta')
	The 't' argument to 'idx_meta' is the _parent_ table, the one on whom
the metamethod is invoked. That table's 1-slot holds the path that leads
down to it. We use that in turn to define the next table's path (see the 'setmetatable' 
call inside 'idx_meta'.)
	That's how we solved the problem of a 'digits' variable not
properly being reset after issuing a command (since the issued commands
get cached in the mode table!) - we now record the digits field as t[1].
	'nprefix' (true, false) tells the mode to use Vi-style numeric arguments.
	From working on the original 'nprefix', I discovered how to block non-bound keys,
even pesky "Scintilla" ones - you simply bind the non-bound key to a 
dummy function that, say, outputs a message and returns true (see the
'setmetatable' call inside 'idx_meta'.)

	name - the name of the mode.
	
	binds - the keybindings the mode is supposed to use.
	
	nprefix - bind digits to form numeric arguments to keybindings, as in Vi.
(boolean.)

	root_binds - in nprefix=true modes, keybindings that don't respond to 
numeric arguments.

	tbc - note that some bindings respond differently to arguments (something
like 1 0 0 G would go to line 100).
]]

local idx_meta 

local function deep_copy (t1)
	local copy = {}
	
	for k,v in pairs(t1) do
		if type(v) == "table" then
			copy[k] = deep_copy(v)
		else
			copy[k] = v
		end
	end
	
	return copy
end

return function (name, binds, nprefix, root_binds)
	
	-- To be on the safe side, clone the given binds, since we might want to play with
	-- variations on the same set of keybindings, yet we don't want to trample their
	-- states in between uses.
	binds = binds and deep_copy(binds)
	root_binds = root_binds and deep_copy(root_binds)
	
	-- Give modes an automatic 'esc' binding, in the tradition of Vi.
	binds.esc = function ()
			ui.statusbar_text = string.format("Left '%s'", name)
			keys.MODE = nil -- exit the mode.
	end
	
	 -- Bind non-bound keys to a dummy function, effectively blocking them.
	setmetatable(binds, {__index = function (t, key)
		t[key] = function ()
			ui.statusbar_text = string.format("unbound: '%s'", key)
			return true
		end
		
		return t[key]
	end})


	idx_meta = function (t, key)
		if tonumber(key) then
			t[key] = setmetatable({t[1]..key}, {__index = idx_meta})
			return t[key]
		else		
			local n_arg = (t[1] == "") and 1 or tonumber(t[1])
	
			t[key] = function ()
				for i = 1, n_arg do
					binds[key]() -- no matter what, this is valid (b/c of binds' metatable.)
				end
			end
		
			return t[key]
		end
	end
	
	-- Initialize the 'digits' path (used to be {""}, but just hitch on root_binds at this point.)
	root_binds = root_binds or {}
	root_binds[1] = ""
	
	-- Interface with TA.
	keys[name] = (nprefix and setmetatable(root_binds, {__index = idx_meta})) or binds 	
	
	-- Return the function that activates the mode (so the caller can bind it to a key).
	return function ()
		ui.statusbar_text = string.format("'%s' mode, hit 'esc' to exit", name)
		keys.MODE = name
	end
end
