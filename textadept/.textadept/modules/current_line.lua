-- Get internal representation of the current line.

return function ()
	local cursor = buffer.current_pos
	return buffer:line_from_position(cursor)
end
