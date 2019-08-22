--[[
	Functions sometimes want to make local, "personal" copies of
tables they're given as parameters, so here it is.
]]

local deep_copy

deep_copy = function (t1)
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

return deep_copy