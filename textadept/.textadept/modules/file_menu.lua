return function ()
	local glossary = {
		New = function () buffer:new() end,
		Open = io.open_file,
		Save = io.save_file,
		Quit =  quit,
	}
	
	local itemization = {}
	
	for option in pairs(glossary) do
		table.insert(itemization, option)
	end
	
	local button, choice = ui.dialogs.filteredlist {
		title = "File Menu",
		columns = {""},
		items = itemization,
		string_output = true,
		width = 250,
		height = 250,
	}
	
	if button == _L["_OK"] then
		return glossary[choice]()
	end
end
		