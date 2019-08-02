
-- Reserve 'glossary[1]' for the menu title.

local function launch_menu (glossary)
	local title = glossary[1]
	local itemization = {}
	
	for word in pairs(glossary) do
		if type(word) ~= "number" then
			table.insert(itemization, word)
		end
	end

	table.sort(itemization, function (w1, w2)
		return w1 < w2
	end)
	
	local body = {	
		title = title,
		columns = {""},
		items = itemization,
		width = 250,
		height = 250,
		string_output = true
	}
	
	local button, choice = ui.dialogs.filteredlist(body)
	
	if button == _L["_OK"] then
		return glossary[choice]()
	end
end

return launch_menu