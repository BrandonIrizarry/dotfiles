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
	"rgb",
	"current_line",
	"select_lines",
	"alert",
	"term",
	"config",
	"rename_file",
	"launch_menu",	
	"directory_menu",
	"toggle_menubar",
	"select_lexified",
	"define_mode",
	"lua_pattern_find", -- from wiki
	"file_browser", -- from wiki
	"elastic_tabstops", -- from wiki
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

	
	local nav_bindings = {
		h = function () buffer:char_left() end,
		j = function () buffer:line_down() end,
		k = function () buffer:line_up() end,
		l = function () buffer:char_right() end,
		cf = function () buffer:page_down() end,
		cb = function () buffer:page_up() end,
		["\n"] = function () buffer:new_line() end,
	}
	
	keys.cj = define_mode("Exp", nav_bindings, true)
	keys.ci = define_mode("Nav", nav_bindings, false)
	
	-- Turn the menubar off.
	--toggle_menubar()	
	
	-- Use Lua patterns for searches, instead of regex.
	-- This turns on the menubar after we've shut it off, so we can't use it for now.
	--lua_pattern_find.toggle_lua_patterns()
	
	-- Use elastic tabstops.
	--elastic_tabstops.enable()
	
	-- Modify cN to select the trailing newline, so that we can indent single lines.
	-- Super-useful for line selection - if you ever have a new binding for single-line
	-- selection, make sure it does this, for heaven's sake!
	keys.cN = function ()
		local line = current_line() + 1 
		select_lines(line, line)
	end
	
	---[[
	keys["c."] = function ()
		buffer:line_end_extend()
	end
	
	keys["c,"] = function ()
		buffer:home_extend()
	end
	--]]
end)