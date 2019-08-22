--[[
	NB: Install xclip first.
]]

local M = {}

function M.clipboard_write (text)
	local handle = io.popen("xclip -selection clipboard", "w")
	handle:write(text)
	handle:close() 
end

function M.clipboard_read ()
  local handle = io.popen("xclip -selection clipboard -o")
  local text = handle:read("a")
  handle:close()
  
  return text
end

-- Copy.
keys.cc = function ()
	local sel = buffer.get_sel_text()
	M.clipboard_write(sel)
end

-- Cut.
keys.cx = function ()
	local sel = buffer.get_sel_text()
	buffer:cut()
	M.clipboard_write(sel)
end

-- Paste.
keys.cv = function () 
	local text = M.clipboard_read() 
	buffer:add_text(text)
end

return M