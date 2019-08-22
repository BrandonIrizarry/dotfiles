local function table_equal (T_1, T_2)
	for k_1, v_1 in pairs(T_1) do
		if (type(v_1) ~= "table") and v_1 ~= T_2[k_1] then
			return false, {k_1, v_1, T_2[k_1]}
		elseif type(v_1) == "table" then
			local result, status = table_equal(v_1, T_2[k_1])
			if result == false then
				return false, status
			end
		end
	end
	
	return true, {"success"}
end

return table_equal