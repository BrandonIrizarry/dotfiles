return function ()
	local color = ui.dialogs.colorselect {
		title = 'Pick a Color', string_output = true
	}

	if color then buffer:insert_text(-1, color) end
end