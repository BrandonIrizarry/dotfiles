if CURSES then
    buffer:set_theme("term-bci")
else
	local FONT_TABLE = { font="Fira Mono", fontsize = 15}
	local THEME	= "dark-bci"

	buffer:set_theme(THEME, FONT_TABLE)
end

-- Disable character autopairing with typeover
textadept.editing.auto_pairs = nil
textadept.editing.typeover_chars = nil


-- Always use tabs of width 4 for indentation.
buffer.use_tabs = true
buffer.tab_width = 4

-- Disable indentation guides
buffer.indentation_guides = buffer.IV_NONE

-- Disable code folding and hide the fold margin
buffer.property.fold = "0"
buffer.margin_width_n[2] = 0