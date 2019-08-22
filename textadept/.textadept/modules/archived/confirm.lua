

return function (question)
	local button = ui.dialogs.ok_msgbox {
		title = "Confirm",
		informative_text = question,
		icon = "gtk-dialog-question",
	}
	
	return ((button == 1) and true) or false
end