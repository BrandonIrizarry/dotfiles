do
	local define_theme = require "define_theme"
	_G.apply_theme = define_theme("sand", "Liberation Mono", 15)
end

apply_theme()

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
  local basename = filename:match("^.+/(.+)")
	ui.statusbar_text = string.format("Wrote file '%s' to disk!", basename)
end)

_C = {}

keys.ce = function ()
	local buffer = ui.command_entry
	
	buffer.enter_mode("lua_command", "lua")
	buffer:set_text("_C.")
	buffer:goto_pos(buffer.length)
end

_C.file = require "file_opener"
keys.co = _C.file
_C.root = require("config").root_config
_C.user = require("config").config
_C.rename = require "rename_file"
_C.lines = require "select_lines"
_C.lexed = require "select_lexified"
_C.reset = _G.reset
_C.buffers = ui.switch_buffer
_C.term = require "term"

--]]

--[[
local my_modlist = {
	"current_line",
	"select_lines",
	"alert",
	"term",
	"config",
	"rename_file",
	"select_lexified",
	"define_mode",
	"deep_copy",
	"nav",
	"god_mode",
	"file_opener",
	"series",
	--"select_command",
}
--]]

--[=[
events.connect(events.INITIALIZED, function ()
	local report
	

	local function load_modules (modlist)
		local lmods = {}
		
		for _, name in ipairs(modlist) do
			local status, mod = pcall(require, name)

			if not status then -- we all know what this means. :)
				return false, string.format("Error in module '%s': \n%s\nAborting config.", name, mod)
			end
			
			-- Check the availability of the module name, before making it global.
			if _G[name] ~= nil then
				return false, string.format("Name '%s' already taken.\nAborting config.", name)
			end
				
			lmods[name] = mod
		end
	
		return true, lmods
	end
	
	do
		local status, lresult = load_modules(my_modlist)
		
		if status then
			for name, mod in pairs(lresult) do
				_G[name] = mod
			end
		
			alert("Success")
		else
			ui.print(lresult)
			return
		end
	end
	
	--keys.au = select_command()
	--[[
	events.connect(events.QUIT, function ()
		local button = ui.dialogs.ok_msgbox {
			title = "Confirm",
			informative_text = "Really quit?",
			icon = "gtk-dialog-question",
		}
	
		return button == 2
	end)
	--]]
	
	-- An example mode.
	--keys.ci = nav.load()
	
	-- Another mode.
	--keys.ci = god_mode.load()

	
	-- Modify cN to select the trailing newline, so that we can indent single lines.
	--[[
	keys.cN = function ()
		local line = current_line() + 1 
		select_lines(line, line)
	end
	]]
	
	keys["c>"] = function ()
		buffer:line_end_extend()
	end
	
	keys["c<"] = function ()
		buffer:home_extend()
	end
	
	keys["ct"] = function ()
		view:goto_buffer(1)
	end
	
	keys["cT"] = function ()
		view:goto_buffer(-1)
	end
	
end)
--]=]