-- Only performs a side-effect on table values.
return function (fn, t)
	for key, value in pairs(t) do
		if type(value) == "table" then
			M.foreach(fn, value)
		else
			fn(value)
		end
	end
end