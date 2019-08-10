--[[
NB: As we're loading the modules, we're not adding them to _G just yet (as we did before),
so I can't count on a module just because it occurs prior in the list.

Modules with dependencies should instead define an "init" method that's usable by the time
all the other modules are loaded into _G (see, for example, "directory_menu", which depends
on "launch_menu".)
]]

events.connect(events.INITIALIZED, function ()
	textadept.menu.menubar = nil
end)

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

	
	keys.cN = function ()
		local line = current_line() + 1 
		select_lines(line, line)
	end
	
	--[[
	function line_endpoints ()
		local cursor = buffer.current_pos
		local line = buffer:line_from_position(cursor) -- internal
		local lstart = buffer:position_from_line(line)
		local lend = buffer.line_end_position[line] + 1

		return lstart, lend
	end
	--]]
	


	

	
	
		
	-- Rebind some keys to acheive similarity to the curses version.
	--[[
	local basic_keys = {
		ck = function()
			buffer:line_end_extend()
			if not buffer.selection_empty then buffer:cut() else buffer:clear() end
		end,
		ca = function () buffer:vc_home() end,
		cu = function ()
			buffer:home_extend()
			if not buffer.selection_empty then buffer:cut() else buffer:clear() end
		end,
		ce = function () buffer:line_end() end,
		aa = function () buffer:select_all() end,
		ac = function () ui.command_entry.enter_mode("lua_command", "lua") end,
		cd = buffer.clear,
		af = function () buffer:word_right() end,
		ab = function () buffer:word_left() end,
		cf = function () buffer:char_right() end,
		cb = function () buffer:char_left() end,
		an = function () view:goto_buffer(1) end,
		ap = function () view:goto_buffer(-1) end,
		["c/"] = ui.find.focus,
		["a/"] = textadept.editing.block_comment,
		ah = textadept.editing.show_documentation,
		ch = ui.switch_buffer,
		caa = function () buffer:document_start() end,
		cae = function () buffer:document_end() end,
		aU = function () buffer:page_up() end,
		aD = function () buffer:page_down() end,
		cp = function () buffer:line_up() end,
		cn = function () buffer:line_down() end,
		cz = function () buffer:zoom_in() end,
		cZ = function () buffer:zoom_out() end,
		az = buffer.undo,
		ar = buffer.redo,
		
		
		cmv = {
			q = function () ui.goto_view(1) ;view:unsplit() end,
			s = function () view:split() end,
			v = function ()	view:split(true) end,
			w = function () view:unsplit() end,
			W = function () while view:unsplit() do end end,
			n = function () ui.goto_view(1) end,
			p = function () ui.goto_view(-1) end,			
		}
	}
	
	local lmod_keys = {
		ax = {
			c = config.config,
			r = config.root_config,
		},
		
		ct = term,
	}

	
	local function load_keys (key_set)	
		for binding, operation in pairs(key_set) do
			keys[binding] = operation
		end
	end

	load_keys(basic_keys)
	load_keys(lmod_keys)
	--]]
	
	--[[
	keys.co = function ()
		return launch_menu:launch({
			Open = directory_menu.init,
			["Open Home"] = function () directory_menu.init(os.getenv("HOME")) end,
			Rename = rename_file,
			Save = io.save_file,
			Close = io.close_buffer,
			Quit = quit,
		}, "File Menu")
	end
	--]]
end)

