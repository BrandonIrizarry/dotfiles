--[[ 
	NB: For bindings, if you return a function, it's executed; if you
return a table, it triggers a keychain.
	To use local functions recursively, you need to first declare
the variable to be used for the function (in this case, 'idx_meta')
	The 't' argument to 'idx_meta' is the _parent_ table, the one on whom
the metamethod is invoked. That table's 1-slot holds the path that leads
down to it. We use that in turn to define the next table's path (see the 'setmetatable' 
call inside 'idx_meta'.)
	That's how we solved the problem of a 'digits' variable not
properly being reset after issuing a command (since the issued commands
get cached in the mode table!) - we now record the digits field as t[1].
	From working on the original 'nprefix', I discovered how to block non-bound keys,
even pesky "Scintilla" ones - you simply bind the non-bound key to a 
dummy function that, say, outputs a message and returns true (see the
'setmetatable' call inside 'idx_meta'.)

	name (string) - the name of the mode.
	
	binds (table) - the keybindings the mode is supposed to use.
	
	nprefix (boolean) - tells the mode to use Vi-style numeric arguments, by binding
digits via metatables to form numeric arguments to keybindings.

	root_binds - in nprefix=true modes, keybindings that don't respond to 
numeric arguments. If nprefix=true, a default root_binds table is used over binds, to
activate the keychain mechanism necessary to enact numeric prefixes. However,
this last parameter can be provided as an initial custom definition of this table.
	Allowing it explicitly as a separate parameter is mainly for keybindings for whom 
numeric prefixes don't make any sense, such as "open file", "open buffer list", 
"show command entry", and so on.

	Modes are given an automatic 'esc' binding for exiting that mode.
This is in the tradition of Vi.
	tbc - note that some bindings respond differently to arguments (something
like 1 0 0 G would go to line 100).
]]



local idx_meta 

return function (name, binds, nprefix, root_binds)
	
	-- To be on the safe side, clone the given binds, since we might want to play with
	-- variations on the same set of keybindings, yet we don't want to trample their
	-- states in between uses.
	binds = binds and deep_copy(binds)
	root_binds = root_binds and deep_copy(root_binds)
	
	 -- Bind non-bound keys to a dummy function, to block them.
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
	
			-- If n_arg were huge, then trying something like "10000000000000w" if 'w' is
			-- unbound, will effectively hang TA - so we check whether we've seen the 'true'
			-- returned by 'binds' metamethod.
			t[key] = function ()
				for i = 1, n_arg do
					local binds_mt = binds[key]()
					
					-- triggered binds' metatable -> key is unbound -> exit, don't waste time looping.
					if binds_mt == true then break end 
				end
			end
		
			return t[key]
		end
	end
	
	-- Initialize 'root_binds', along with its "digits" path.
	root_binds = root_binds or {}
	root_binds[1] = ""
	
	local function exit ()
		ui.statusbar_text = string.format("Left '%s'", name)
		keys.MODE = nil -- exit the mode.
	end
	
	-- Interface with TA. The lhs of the 'or' is for numeric sensitive binds;
	-- the rhs uses the binds table "raw".
	keys[name] = (nprefix and setmetatable(root_binds, {__index = idx_meta})) or binds
	
	-- Note that, for nprefix binds, 'esc' is a top-level binding, so as not to trigger metatable code
	-- when debugging. For nprefix=false, it's enough to just join it to 'binds'.
	keys[name].esc = exit
	
	-- Return the function that activates the mode (so the caller can bind it to a key).
	return function ()
		ui.statusbar_text = string.format("'%s' mode, hit 'esc' to exit", name)
		keys.MODE = name
	end
end
