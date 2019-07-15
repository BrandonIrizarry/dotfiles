--[[
	Routines for reading and writing to the clipboard from curses.
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

return M

