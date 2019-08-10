--[[
	Select from the beginning of 'start_line' to the end of 'end_line'.
	A prefix of '__' refers to the internal, zero-indexed representation of lines.
]]

return function (lno_start, lno_end)
		local __cline = current_line()
		
		local __lno_start = (lno_start and lno_start - 1) or 0
		local __lno_end = (lno_end and lno_end - 1) or buffer.line_count + 1
		
		-- Endpoints.
		local left = buffer:position_from_line(__lno_start)
		local right = buffer.line_end_position[__lno_end] + 1
		
		buffer:set_sel(left, right)
end