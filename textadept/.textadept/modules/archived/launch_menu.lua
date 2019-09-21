--[[
	NB: We can't have prototypal objects be modules, since, if we
modify the object/module's fields, we can never get the factory-defaults
version back, because 'require' doesn't reload modules.
	So make the original, module-based object a read-only table, and arrange 
things such that its clones are read/write.

Example usage:

keys.co = function ()
	return launch_menu:launch({
		Open 			= directory_menu.init,
		["Open Home"] 			= function () directory_menu.init(os.getenv("HOME")) end,
		Rename 			= rename_file,
		Save			= io.save_file,
		Close 			= io.close_buffer,
		Quit 			= quit,
	}, "File Menu")
end
]]

local DEFAULT_WIDTH = 250
local DEFAULT_HEIGHT = 250

local M = {}

M.body = {
	columns = {""},
	items = {},
	width = DEFAULT_WIDTH,
	height = DEFAULT_HEIGHT,
	string_output = true,
}

M.sort = function (w1, w2) return w1 < w2 end

function M:launch (glossary, title)
	local itemization = {}
	
	for word in pairs(glossary) do
		table.insert(itemization, word)
	end
		
	table.sort(itemization, self.sort)
	self.body.items = itemization
	
	if title then
		local normalized = #title * 20
		self.body.title = title
		self.body.width = (normalized >= DEFAULT_WIDTH) and normalized or DEFAULT_WIDTH
	end
	
	local button, choice = ui.dialogs.filteredlist(self.body)
	
	if button == _L["_OK"] and choice then
		glossary[choice]()
	elseif not choice then
		alert("Invalid choice")
	end
end

--[[
	See p. 195 of PIL 4.
	NB: Setting the proxy table's __index field must be done outside
of 'clone', since calls to 'clone' will occur after closing,
and so setting an __index field on it will raise an error.
	Based on the original 'M:clone' function (something
like what appears on p. 200 of PIL 4.)
]]

local proxy = {}
proxy.__index = proxy -- lead accesses to M's fields back to proxy's metatable
proxy.name = "launch_menu"

-- Note that 'proxy' doesn't have a '__newindex' method, so clones are writable.
function proxy:clone ()
	local lm = {}
	return setmetatable(lm, self)
end

local mt = {
	__index = M, 
	__newindex = function (t)
		local message = string.format("Module '%s' is read-only; use 'clone'.", t.name)
		error(message, 2)
	end
}

setmetatable(proxy, mt)

return proxy
