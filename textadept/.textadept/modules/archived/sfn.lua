local Standard = {}

local function standardize (fn)
	local dumped = string.dump(fn)
	
	local std = (dumped:gsub("()(.)", function (index, char)
		local col_number = index % 20 -- fit output comfortably onto screen.
		local hf = "\\x"..string.format("%02X", string.byte(char))
		
		return (col_number == 0 and (hf.."\\z\n")) or hf
	end))
	
	return '"'..std..'"'
end

local function serialize (fn)

	-- Get all of fn's upvalues.
	local upvalues = {} 
	for i = 1, math.huge do
		local name, value = debug.getupvalue(fn, i)
		if not name then break end -- check existence
		
		if type(value) == "function" then
			serialize(value)
		end
		
		table.insert(upvalues[serialize(fn)], value)
	end
	
	-- Wrap C functions in thunks.
	local what = debug.getinfo(fn, "S").what	
	if what == "C" then
		fn = function (...) fn(...) end
	end
		
	return standardize(fn), upvalues
end

function Sfn:new (fn)
	local self.fn = fn
	
	-- Create a table of fn->upvalues, also for
	-- upvalues that are functions.
	for i = 1, math.huge do
		local name, value = debug.getupvalue(fn, i)
		if not name then break end -- check existence
		
		if type(value) == "function" then
			serialize(value)
		end
		
		table.insert(upvalues[serialize(fn)], value)
	end
end

return M