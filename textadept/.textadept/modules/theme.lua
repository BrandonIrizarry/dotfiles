local theme, font_table

if CURSES then
	theme = "term-bci"
else
	--theme = "dark"
	theme = "sand"
	font_table = { 
	--	font = "Fira Mono", 
		fontsize = 15
	}
end

buffer:set_theme(theme, font_table)

-- Always use tabs of width 4 for indentation.
buffer.use_tabs = true
buffer.tab_width = 4

-- Disable indentation guides
buffer.indentation_guides = buffer.IV_NONE

-- Disable code folding and hide the fold margin
buffer.property.fold = "0" 
buffer.margin_width_n[2] = 0

-- Disable character autopairing with typeover
textadept.editing.auto_pairs = nil
textadept.editing.typeover_chars = nil