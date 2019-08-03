
local M = {}

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