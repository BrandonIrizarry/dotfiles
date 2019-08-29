--[[
	Notes:
	
	The 'line_end' method doesn't work after multiple presses of the Tab key,
so we use 'goto_pos' instead.
	Some characters (such as hyphens) have a special meaning in Lua patterns,
so we have to escape them.
	Unselecting the displayed path only works _after_ entering the mode.
]]

local dir_stack = require "file_opener.dir_stack"
local ls_command = "ls -ap"

keys.file_opener = {
	["\t"] = function ()
		local dir, part = dir_stack(ui.command_entry:get_text())
		ui.command_entry:set_text(dir..part)
		ui.command_entry:goto_pos(ui.command_entry.length)
		
		local list = {}
	
		local prefix = "^"..part:gsub("%-", "%%-")
		
		for entry in io.popen(ls_command.." "..dir):lines() do
			if entry:match(prefix) then
				list[#list + 1] = entry
			end
		end
		
		table.sort(list)
		
		list = table.concat(list, " ")
		ui.command_entry:auto_c_show(#part, list)
	end,
	
	["\n"] = function ()
		return ui.command_entry.finish_mode(io.open_file) 
	end
}

keys.co = function ()
	ui.command_entry:set_text(buffer.filename:match(".*/") or os.getenv("HOME").."/")
	ui.statusbar_text = "Enter path:"
	ui.command_entry.enter_mode("file_opener")
	
	ui.command_entry:set_empty_selection(ui.command_entry.length)
end