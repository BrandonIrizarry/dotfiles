return function ()
	local glossary = {
		{"Open", io.open_file},
		{"New", function () buffer:new() end,},
		{"Rename", rename_file},
		{"Save", io.save_file},
		{"Close", io.close_buffer},
		{"Quit", quit},
	}
	
	local itemization = {}
	for _, binding in ipairs(glossary) do
		table.insert(itemization, binding[1])
	end
	
	
	local button, idx = ui.dialogs.filteredlist {
		title = "File Menu",
		columns = {""},
		items = itemization,
		width = 250,
		height = 250,
	}
	
	if button == 1 then
		return glossary[idx][2]()
	end
end
