--[[
	NB: We can't have prototypal objects be modules, since, if we
modify the object/module's fields, we can never get the factory-defaults
version back, because 'require' doesn't reload modules. So, whenever we need
a factory-defaults version of the object, we must make the object's definition 
from scratch once again, hence 'MOD.init'.
	We found it convenient to have 'init' accept an initial default sort function.
]]

local MOD = {}

local DEFAULT_WIDTH = 250
local DEFAULT_HEIGHT = 250

function MOD.init (sort)
	local M = {}
	
	M.body = {
		columns = {""},
		items = {},
		width = DEFAULT_WIDTH,
		height = DEFAULT_HEIGHT,
		string_output = true,
	}

	M.sort =  sort or function (w1, w2) return w1 < w2 end

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

	function M:clone ()
		local lm = {}	
		self.__index = self
		return setmetatable(lm, self)
	end
	
	return M
end

return MOD