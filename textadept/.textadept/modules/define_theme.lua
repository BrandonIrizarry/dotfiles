--[[
	To avoid setting environment variables in a chunk, we use higher order
functions:
	
	local define_theme = require "define_theme"
	_G.apply_theme = define_theme("sand", "Liberation Mono", 15)
	apply_theme()
	
	The function returned applies the theme for a particular buffer. We need this
occasionally for when we change the theme, but the command entry hasn't kept up
with the changes, in which case we'd do:

	apply_theme(ui.command_entry)
]]

return function (theme, font, fontsize)
	return function (buffer)
		buffer = buffer or _G.buffer
		buffer:set_theme(theme, {font=font, fontsize=fontsize})

		-- Always use tabs of width 4 for indentation.
		buffer.use_tabs = true
		buffer.tab_width = 4

		-- Disable indentation guides
		buffer.indentation_guides = buffer.IV_NONE

		-- Disable code folding and hide the fold margin
		buffer.property.fold = "0" 
		buffer.margin_width_n[2] = 0

		-- Disable character autopairing with typeover
		local textadept = _G.textadept
		textadept.editing.auto_pairs = nil
		textadept.editing.typeover_chars = nil
	end
end