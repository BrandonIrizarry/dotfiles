return function ()
	local button, new_name = ui.dialogs.inputbox {
		title = "Rename This File",
		informative_text = "Choose a New Name",
		width = 300,
	}
	
	if button == 1 then
		io.save_file() -- save to disk before renaming, since we'll be loading again from disk.
		local full_path = buffer.filename
		local new_name = full_path:gsub("^(.*)/(.+)$", "%1/"..new_name)
		os.rename(full_path, new_name)
		buffer.filename = new_name 
		io.reload_file()
	end
end