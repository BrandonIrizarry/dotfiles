--[[
NB: As we're loading the modules, we're not adding them to _G just yet (as we did before),
so I can't count on a module just because it occurs prior in the list.

Modules with dependencies should instead define an "init" method that's usable by the time
all the other modules are loaded into _G (see, for example, "directory_menu", which depends
on "launch_menu".)
]]

require "theme"

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	ui.statusbar_text = string.format("Wrote file '%s' to disk!", basename)
end)

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
	"select_command",
}

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
	
	keys.au = select_command()
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
	keys.ci = god_mode.load()

	
	-- Modify cN to select the trailing newline, so that we can indent single lines.
	-- Super-useful for line selection - if you ever have a new binding for single-line
	-- selection, make sure it does this, for heaven's sake!
	keys.cN = function ()
		local line = current_line() + 1 
		select_lines(line, line)
	end
	
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