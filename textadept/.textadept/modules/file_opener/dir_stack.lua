--[[
	This function lets up process a directory string as if it were a 
set of instructions on a stack. We can now more easily handle "../"
to move up in the directory tree.
]]

local function dir_stack (path)
	local exec = path:match("[^/]+$") or ""
	
	local stack = {}
	for instr in path:gmatch(".-/") do
		if instr == "../" then
			table.remove(stack)
		else
			table.insert(stack, instr)
		end
	end
		
	local dir = table.concat((#stack == 0) and {"/"} or stack)
	return dir, exec
end
		
return dir_stack
	