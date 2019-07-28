--[[
	General system commands.
	Note that, when dealing with lines, you have to translate user-inputted line numbers
to the zero-indexed ones that Textadept uses internally.
]]

local system = {} 

system.run = textadept.run.run
system.quit = quit

function system.config ()
	io.quick_open(_USERHOME)
end

function system.root_config ()
	io.quick_open(_HOME)
end

function system.term ()
	os.spawn("xterm", buffer.filename:match(".*/") or os.getenv("HOME"))
end

function system.reset ()
	if _G.buffer.modify then -- buffer has unsaved changes.
		io.save_file() -- presumably something like 'init.lua'
	end
	
	_G.reset()
end

function system.select (start_line, end_line)
	local pos_a = (start_line == nil) and 0	or _G.buffer:position_from_line(start_line - 1)
	local pos_b = (end_line == nil) and _G.buffer.length or _G.buffer.line_end_position[end_line - 1]
	
	buffer:set_selection(pos_b, pos_a)
end

return system
