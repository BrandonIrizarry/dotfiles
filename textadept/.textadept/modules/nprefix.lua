--[[ 
	NB: For bindings, if you return a function, it's executed; if you
return a table, it triggers a keychain.
	Also, to use local functions recursively, you need to first declare
the variable to be used for the function (in this case, 'idx_meta')
	tbc - I just noticed something awesome - all non-set keybindings are
now infallibly BLOCKED!!!
]]

local M = {}

function M.init (binds)

	local idx_meta 

	idx_meta = function (t, key)
		if tonumber(key) then
			t[key] = setmetatable({t[1]..key}, {__index = idx_meta})
			return t[key]
		else		
			local n_arg = (t[1] == "") and 1 or tonumber(t[1])
	
			if binds[key] then
				t[key] = function ()
					for i = 1, n_arg do
						binds[key]()
					end
				end
			else
				t[key] = function ()
					local msg = "Can't use '%s'"
					ui.statusbar_text = string.format(msg, key) 
					return true
				end
			end
			
			return t[key]
		end
	end

	return setmetatable({""}, {__index = idx_meta})
end

return M
