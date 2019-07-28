--[[
	Select from the beginning of 'start_line' to the end of 'end_line'.
]]

return function (start_line, end_line)
	local pos_a = (start_line == nil) and 0	or buffer:position_from_line(start_line - 1)
	local pos_b = (end_line == nil) and buffer.length or buffer.line_end_position[end_line - 1]
	
	buffer:set_selection(pos_b, pos_a)
end