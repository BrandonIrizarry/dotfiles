local function map (fn, t)
	local t_copy = {} -- tbc
	
	for key, value in pairs(t) do
		if type(value) == "table" then
			t_copy[key] = map(fn, value)
		else
			t_copy[key] = fn(value)
		end
	end
	
	return t_copy
end

return map