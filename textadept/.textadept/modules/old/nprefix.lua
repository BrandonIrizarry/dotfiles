--[[ 
	This is basically it - we can now use Vim-like numerical prefixes
for modal commands.
	We'd need to clean up how 'digits' gets reset. 
	Consider setting it back to accepting all values of key for 
binds[key] (no sdigits, no return true), and start again from there. tbc.
]]

local M = {}

local augmented = {}

function M.init ()

	local idx_meta -- need to declare separately, to use recursively!

	local digits = ""

	-- The 'binds' reference.
	local binds = {
		a = function () ui.print("A") end,
		b = function () ui.print("B") end,
	}

	local count = 0

	idx_meta = function (t, key)
		alert("key is:", key)
		if tonumber(key) then
			t[key] = setmetatable({}, {__index = idx_meta})
			digits = digits..key
			alert(digits)
			return t[key]
		else		
			-- For bindings, if you return a function, it's executed; if you
			-- return a table, it triggers a keychain.
			local n_arg = tonumber(digits)
			alert("digits/n_arg is:", digits, n_arg)
			digits = "" -- I want the reset to happen here, no matter what key is pressed, when.
			alert(count, key)
			count = count + 1
			
			
			if binds[key] then
				t[key] = function (n_arg)
					alert("sum inside new function:", n_arg, type(n_arg))
					for i = 1, n_arg do
						binds[key]()
					end
				end
			else
				t[key] = function ()
					--ui.statusbar_text = t.tfield
					return true
				end
			end
			
			return t[key]
		end
	end

	return setmetatable({}, {__index = idx_meta})
end

return M
