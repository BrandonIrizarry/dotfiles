-- Pressing C-z will undo, instead.
events.connect(events.SUSPEND, function()
	buffer:undo()
	return true
end, 1)

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	ui.statusbar_text = string.format("Wrote file '%s' to disk!", basename)
end)

-- Fill in some missing 'view' keybindings.
keys.cmv.q = function ()
	ui.goto_view(1)
	view:unsplit()
end

local modules = {
	"utils",
	"copy_paste",
	"config",
	"view_modal",
}

-- Theming has to be done before initialization is complete.
require "theme"

events.connect(events.INITIALIZED, function ()
	local report
	
	for _, mod in ipairs(modules) do
		local status, result = pcall(require, mod)

		if not status then -- we all know what this means. :)
			report = string.format("Error in module '%s':\n%s\nAborting config.", mod, result)
			break
		end
		
		-- Check the availability of the module name, before making it global.
		if _G[mod] ~= nil then
			report = string.format("Name '%s' already taken.", mod)
			break
		end
			
		_G[mod] = result
	end
	
	local NOTIFY_STATUS = report and ui.print or utils.alert
	NOTIFY_STATUS(report or "Success.")
	
	function naive_clone (fn)
		return load(string.dump(fn))
	end
	
	function get_upvalues (fn)
		local i = 1
		while true do
			local name = debug.getupvalue(fn, i)
			if not name then
				break
			end
			ui.print(name)
			i = i + 1
		end
	end
	
	non_printable = {}
	types = {}

	local glossary = {
		["\n"] = "\\n",
		["\t"] = "\\t",
		["\b"] = "\\b",
		["\\"] = "\\\\",
		["\r"] = "\\r",
	}
	
	function make_printable (str)
		return str:gsub(".", function (c)
			return glossary[c] or c
		end)
	end
	
	LUA_IDENTIFIER = "^[%a_][%w_]*$"
	
  
	function force_valid_key (str)
		str = make_printable(str)
		
		if str:match(LUA_IDENTIFIER) then
			return str
		else
			return '["'..str..'"]'
		end
	end
			
	local function fetch_non_printable (str)
		for i = 1, #str do
			local char = str:sub(i,i)
			if char:match("%G") then
				non_printable[string.byte(char)] = true
				ui.print(i, string.byte(char), ",")
			end
		end
	end
	
	-- C functions can't be dumped (naive_clone), so we have to wrap them in thunks
	-- to accomplish this.
	function list ()
		for binding, fn in pairs(keys) do
			ui.print(binding)
			
			if not binding:match(LUA_IDENTIFIER) then 
				ui.print("OOPS") 
				fetch_non_printable(binding)
			end
			
			if type(fn) == "function" then
				local what = debug.getinfo(fn, "S").what
				if what == "C" then
					fn = function () fn() end
				end
				get_upvalues(fn)	
			elseif type(fn) == "table" then
				ui.print(type(fn), "OTHER")
				ui.print(binding)
			elseif type(fn) == "string" then
				ui.print(fn, "STRING")
			else
				types[type(fn)] = true
			end

			ui.print(string.rep("-", 50))
		end
	end

	function serialize (obj)
		local _type = type(obj)
		if _type == "number" or
			_type == "string" or
			_type == "boolean" or
			_type == "nil" then
			return string.format("%q", obj)
		elseif _type == "table" then
			local result_buffer = {}
			table.insert(result_buffer, "{\n")
			
			for key, value in pairs(obj) do
				if type(key) == "string" then
					table.insert(result_buffer, " "..force_valid_key(key).." = ")
				else
					table.insert(result_buffer, " ["..string.format("%q", key).."]".." = ")
				end
				
				table.insert(result_buffer, serialize(value))
				table.insert(result_buffer, ",\n")
			end
			table.insert(result_buffer, "}\n")
			return table.concat(result_buffer)
		elseif _type == "function" then
			local what = debug.getinfo(obj, "S").what
			if what == "C" then
				obj = function () obj() end
			end
			
			-- tbc - you're going to have to format the dumped function
			-- (which comes out as a binary string)
			-- as a valid Lua literal, using the escape sequence \x for
			-- all bytes (see p. 104 in PIL4.) Use the 
			-- escape sequence \z to break long lines.
			-- (You might want to look at your current solution to that
			-- problem.) -- e.g. there is garbage - quote characters, newlines and such,
			-- that ruin the syntactic validity of the serialized table.
			return string.dump(obj)
		end
	end
	
	--serialize(keys)

	function rebind ()
		local keys = {}
		for binding, fn in pairs(_G.keys) do
			if type(fn) ~= "function" then
				goto continue
			end
			
			local what = debug.getinfo(fn, "S").what
			if what == "C" then
				fn = function () fn() end
			end
			
			keys[binding] = naive_clone(fn)
			
			::continue::
		end
		
		return keys
	end
	
	-- The following doesn't work (weird effects: can type in cmd entry, 
	-- but backspace key deletes in main buffer, not cmd entry.)
	-- Will need to make a full copy of the keys table.
	--keys = setmetatable(rebind(), {__index = keys})
	
	
end)