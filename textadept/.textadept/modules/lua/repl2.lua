--[[ 

Variation on TLS REPL.  

Original license:
Copyright 2014-2019 Mitchell mitchell.att.foicica.com. See LICENSE.
]]

local M = {}

-- A special environment for a Lua REPL.
-- It has an `__index` metafield for accessing Textadept's global environment.
local env
local prompt = "--BEGIN\n"

local START


-- Creates a Lua REPL in a new buffer.
function M.new_repl()
	buffer.new()._type = "[Lua REPL]"
	buffer:set_lexer("lua")
	buffer:add_text("-- Lua REPL (Variation)")
	buffer:new_line()
	
	-- Display the prompt symbol.
	buffer:add_text(prompt)
	
	-- Save the place where user will start to write a chunk.
	START = buffer.current_pos
	
	--[[
	keys.lua['\b'] = function ()
		if buffer._type ~= "[Lua REPL]" then return false end -- propagate
		if buffer.current_pos < START then 
			alert(nil, START)
			buffer:add_text("") 
		end
	end
	--]]
	
	-- Don't consider the buffer modified.
	buffer:set_save_point()
	
	env = setmetatable({
		print = function(...)
			buffer:add_text("--> ")
			local args = table.pack(...)
			
			for i = 1, args.n do
				buffer:add_text(tostring(args[i]))
				if i < args.n then buffer:add_text("\t") end
			end
			  
			buffer:new_line()
		end
	}, {__index = _G})
	
	--[[
	buffer.margin_text[buffer:line_from_position(START)] = "*"
	buffer.margin_type_n[1] = buffer.MARGIN_TEXT
	buffer.margin_width_n[1] = 20
	--]]
	
	--[[
	events.connect(events.UPDATE_UI, function ()
		if buffer._type == "[Lua REPL]" then
			if buffer.current_pos < START then
				buffer.goto_pos(START)
			end
		end
	end)
	--]]
end

-- Evaluates as Lua code the current line or the text on the currently selected
-- lines.
-- If the current line has a syntax error, it is ignored and treated as a line
-- continuation.
function M.evaluate_repl()
	local code, line
	
	-- use line as inputreset
	--code = string.sub(buffer:get_cur_line(), 2)
	code = buffer:text_range(START, buffer.length)
	
	--line = buffer:line_from_position(buffer.current_pos)
	
	-- This is how we can extend chunks to be multi-line, tbc.
	--alert(1, buffer:text_range(START, buffer.length))

	-- Compile the chunk.
	local f = load(code, "repl", "t", env)
	
	-- Propagate keypress when selection is active.
	if not (f and buffer.selection_empty) then return false end 
	
	-- Move down to prepare for next input.
	--buffer:goto_pos(buffer.line_end_position[line])
	buffer:goto_pos(buffer.length)
	buffer:new_line()
	
	-- Invoke/run the chunk.
	if f then 
		f, result = pcall(f) 
	end
  
	if result then
		buffer:add_text('--> ')
		buffer:add_text(tostring(result):gsub('(\r?\n)', '%1--> '))
		buffer:new_line()
	end
	
	buffer:add_text(prompt)
	START = buffer.current_pos
	--buffer:margin_text_clear_all()
	--buffer.margin_text[buffer:line_from_position(START)] = "*"
	
	--[[
	keys.lua['\b'] = function ()
		if buffer._type ~= "[Lua REPL]" then return false end -- propagate
		if buffer.current_pos < START then buffer:add_text("") end
	end
	--]]
	
	buffer:set_save_point()
end

return M