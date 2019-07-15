local _C = {} 

function _C.term ()
	-- If the buffer isn't visiting a file, then there's no directory - launch in $HOME.
	os.spawn("xterm", buffer.filename:match(".*/") or os.getenv("HOME"))
end

_C.run = textadept.run.run

function _C.reset ()
	-- Only save if there are unsaved changes (that is, we may care to first
	-- "save by hand", because we know we're resetting, and we have that habit.)
	if buffer.modify then
		io.save_file() -- presumably 'init.lua', or else the config file you're editing.
	end
	
	reset()
end

_C.quit = quit

function _C.select (start_line, end_line)
  
	-- Be sure to translate to "internal lines".
	local pos_a = (start_line == nil) and 0	or buffer:position_from_line(start_line - 1)
	local pos_b = (end_line == nil) and buffer.length or buffer.line_end_position[end_line - 1]
	
	buffer:set_selection(pos_b, pos_a)
end

return _C
