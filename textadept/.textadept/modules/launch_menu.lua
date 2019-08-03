
local M = {}

local DEFAULT_WIDTH = 250
local DEFAULT_HEIGHT = 250

M.body = {
	columns = {""},
	items = {},
	width = DEFAULT_WIDTH,
	height = DEFAULT_HEIGHT,
	string_output = true,
}

M.sort = function (w1, w2) return w1 < w2 end

function M:launch (glossary)
	local itemization = {}
	
	for word in pairs(glossary) do
		table.insert(itemization, word)
	end
		
	table.sort(itemization, self.sort)
	self.body.items = itemization
	
	local button, choice = ui.dialogs.filteredlist(self.body)
	
	if button == _L["_OK"] and choice then
		glossary[choice]()
	elseif not choice then
		alert("Invalid choice")
	end
end

function M:clone (title)
	local lm = {}	
	self.__index = self
	setmetatable(lm, self)
	
	local normalized = #title * 20
	lm.body.title = title
	lm.body.width = (normalized >= DEFAULT_WIDTH) and normalized or DEFAULT_WIDTH
	
	return lm
end

return M

--[[
function M.init (title, sort)
	return function (glossary)
		local itemization = {}

		for word in pairs(glossary) do
			table.insert(itemization, word)
		end

		sort = sort or function (w1, w2) return w1 < w2 end
		
		table.sort(itemization, sort)
		
		local normal_width = #title * 20
		local body = {	
			title = title or "",
			columns = {""},
			items = itemization or {},
			width = (normal_width >= 250) and normal_width or 250,
			height = 250,
			string_output = true
		}
		
		local button, choice = ui.dialogs.filteredlist(body)
		
		if button == _L["_OK"] and choice then
			glossary[choice]()
		elseif not choice then
			alert("Invalid choice")
		end
	end
end

return M
--]]