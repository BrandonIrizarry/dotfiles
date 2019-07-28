local M = {}

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

local LUA_IDENTIFIER = "^[%a_][%w_]*$"


local function force_valid_key (str)

	-- Fix all non-printable characters.
	str = str:gsub(".", function (c)
		return glossary[c] or c
	end)
	
	-- Literalize any non-identifiers.
	if str:match(LUA_IDENTIFIER) and (not keywords[str]) then
		return str
	else
		return '["'..str..'"]'
	end
end

--[[
local function escape (str)
	return (str:gsub("()(.)", function (index, char)
		local col_number = index % 20 -- fit output comfortably onto screen.
		local hf = "\\x"..string.format("%02X", string.byte(char))
		
		return (col_number == 0 and (hf.."\\z\n")) or hf
	end))
end
--]]


M._DUMPED = {}

function M.serialize (obj)
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
			
			table.insert(result_buffer, M.serialize(value))
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
		M._DUMPED[serialized_fn] = true
		return '"'..escape(serialized_fn)..'"'
	end
end

local function revive_fns (val)
	if M._DUMPED[val] then
		return load(val)
	else
		return val
	end
end

function M.revive (str)
	local map = require "map"
	local _presult = load("return " .. str)()
	return map(revive_fns, _presult)
end

return M