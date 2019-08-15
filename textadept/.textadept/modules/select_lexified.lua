return function ()
	repeat
		local here = buffer.style_at[buffer.current_pos] -- get style code
		buffer:char_left()
	until (buffer.style_at[buffer.current_pos] ~= here) or buffer.current_pos == 0

	-- Cursor ends up at the _left_ of the first not-alike character, so adjust.
	if buffer.current_pos ~= 0 then buffer:char_right() end
	
	repeat
		local here = buffer.style_at[buffer.current_pos]
		buffer:char_right_extend()
	until (buffer.style_at[buffer.current_pos] ~= here) or buffer.current_pos == buffer.length 
end
