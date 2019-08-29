local M = {}

function M.check_double_dot (dir)
	local ps = {}
	local last
	
	for parent in dir:gmatch(".-/") do
		ps[#ps + 1] = parent
		last = parent 
	end
	
	if last == "../" then
		table.remove(ps)
		table.remove(ps)
	
		if #ps == 0 then
			ps = {"/"}
		end
	end
	
	return table.concat(ps)
end

M.dir = "/home/brandon/../"

return M