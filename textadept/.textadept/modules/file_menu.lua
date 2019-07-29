return function ()
	local options = {
		"Open",
		"New",
		"Rename",
		"Save",
		"Close",
		"Quit",
	}
	
	local effects = {
		io.open_file,
		function () buffer:new() end,
		rename_file,
		io.save_file,
		io.close_buffer,
		quit,
	}
	
	local button, idx = ui.dialogs.filteredlist {
		title = "File Menu",
		columns = {""},
		items = options,
		width = 250,
		height = 250,
	}
	
	if button == 1 then
		return effects[idx]()
	end
end
		