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
	"alert",
	"term",
	"config",
	"select_lines",
	"file_menu"
}

events.connect(events.INITIALIZED, function ()
	local report
	
	local function load_modules (modlist)
		local lmods = {}
		
		for _, name in ipairs(modlist) do
			local status, mod = pcall(require, name)

			if not status then -- we all know what this means. :)
				return false, string.format("Error in module '%s': \n%sAborting config.", name, mod)
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
		
	-- Rebind some keys to acheive similarity to the curses version.
	local basic_keys = {
		ck = function () buffer:del_line_right() end,
		cu = function () buffer:del_line_left() end,
		ca = function () buffer:vc_home() end,
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
		cl = ui.switch_buffer,
		ch = function () buffer:page_down() end,
		cH = function () buffer:page_up() end,
		cp = function () buffer:line_up() end,
		cn = function () buffer:line_down() end,
		
		
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
		co = file_menu,
	}
  
	local function load_keys (key_set)	
		for binding, operation in pairs(key_set) do
			keys[binding] = operation
		end
	end
	
	load_keys(basic_keys)
	load_keys(lmod_keys)
end)

