--[[

	Summary

	This is basically a really quick "Find Next". Calling this
	function will take you to the next (or previous) occurrence of
	the word under the cursor.
]]

return function (reverse)
	
	local s = buffer.selection_start
		local e = buffer.selection_end
		
	if s == e then
		s = buffer:word_start_position(s)
				e = buffer:word_end_position(s)
	end
		
		-- Define our word to be searched for.
	local word = buffer:text_range(s, e)
		
		-- No word is detected under cursor.
	if word == '' then return end
		
		-- Search how we come across words.
	--buffer.search_flags = buffer.FIND_WHOLEWORD + buffer.FIND_MATCHCASE
		-- Ideally, we'd use Lua patterns or a regexp at this point, 
		-- occasionally specifying if we want the search to be literal.
		buffer.search_flags = buffer.FIND_MATCHCASE
		
	if reverse then
				-- Search from just before beginning of the current occurrence,
				-- to beginning of the buffer.
		buffer.target_start = s - 1
		buffer.target_end = 0
	else
				-- Search from just after the end of the current occurrence,
				-- to the end of the buffer.
		buffer.target_start = e + 1
		buffer.target_end = buffer.length
	end
		
		-- Wrap the search if the word wasn't found.
		-- Perform the inverse action of either respective search.
	if buffer:search_in_target(word) == -1 then
				
				-- Let the user know we've wrapped, to ease confusion.
				ui.statusbar_text = "Search wrapped."

		if reverse then
			buffer.target_start = buffer.length
			buffer.target_end = e + 1
		else
						
			buffer.target_start = 0
			buffer.target_end = s - 1
		end
				
				-- Word still not found, oh well.
		if buffer:search_in_target(word) == -1 then 
					ui.statusbar_text = 
						"This is the only occurrence of this word."
					return 
				end
	end
		
		-- 'search_in_target' was successful, so these two quantities are set.
		-- Therefore, have them define the selection, and Jake's your uncle.
	buffer:set_sel(buffer.target_start, buffer.target_end)
end