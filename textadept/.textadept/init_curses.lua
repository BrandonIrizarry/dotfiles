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
	
	local keywords = {
		["end"] = true,
	}
	
	function make_printable (str)
		return str:gsub(".", function (c)
			return glossary[c] or c
		end)
	end
	
	LUA_IDENTIFIER = "^[%a_][%w_]*$"
	
  
	function force_valid_key (str)
		str = make_printable(str)
		
		if str:match(LUA_IDENTIFIER) and (not keywords[str]) then
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

	-- The improved version of 'escape', breaking long lines in 'str'.
	function escape (str)
		return (str:gsub("()(.)", function (index, char)
			local col_number = index % 20 -- fit output comfortably onto screen.
			local hf = "\\x"..string.format("%02X", string.byte(char))
			
			return (col_number == 0 and (hf.."\\z\n")) or hf
		end))
	end
	
	_DUMPED = {}
	
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
			
			local serialized_fn = string.dump(obj)
			_DUMPED[serialized_fn] = true
			return '"'..escape(serialized_fn)..'"'
		end
	end
	
	function map (fn, t)
		local t_copy = {}
		
		for key, value in pairs(t) do
			if type(value) == "table" then
				t_copy[key] = map(fn, value)
			else
				t_copy[key] = fn(value)
			end
		end
		
		return t_copy
	end
	
	function revive (val)
		if _DUMPED[val] then
			return load(val)
		else
			return val
		end
	end
	
	
	function table_equal (T_1, T_2)
		for k_1, v_1 in pairs(T_1) do
			if (type(v_1) ~= "table") and v_1 ~= T_2[k_1] then
				return false, {k_1, v_1, T_2[k_1]}
			elseif type(v_1) == "table" then
				local result, status = table_equal(v_1, T_2[k_1])
				if result == false then
					return false, status
				end
			end
		end
		
		return true, {"success"}
	end

	
	function s_fns (t)
		return map(function (val) 
			if type(val) == "function" then 
				local what = debug.getinfo(val, "S").what
				if what == "C" then
					val = function () val() end
				end
				
				return string.dump(val)
			else
				return val
			end
		end, t)
	end
	
	_presult = load("return "..serialize(keys))()
	
	-- nb : the call claims that the two tables have different contents somewhere:
	-- maybe because of the wrapping of C functions as Lua functions :)
	function process_successful (t)
		local res2, status2 = table_equal(s_fns(t), _presult)
		status2 = map(function (val) 
			return glossary[val] or val
		end, status2)
    
		utils.alert(#status2, table.unpack(status2), type(status2[3]), #status2[2], #status2[3], status2[2] == status2[3])
	end
	
	keys = map(revive, _presult) -- this seems to work now!
	-- tbc: now you have to convert all "m" keybindings to "a" 
	-- keybindings (before or after serializing? Before looks good:
	-- keys.af = keys.mf; keys.mf = nil is the basic idea.)
	-- serialize, write to disk, then have the GUI TA load that
	-- keys table, and Jake's your uncle.
	
	--[[
	function revive_functions (proto)
		for key, value in pairs(proto) do
			if type(value) == "table" then
				revive_functions(value)
			elseif _DUMPED[value] then
				proto[key] = load(load("return "..value)())
			end
		end
	end
--]]

	--revive_functions(_RESULT)
	
	--[[
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
	--]]	
end)