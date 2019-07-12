-- Adapted from the "yanksel" plugin from
-- https://github.com/luakit/luakit-plugins/blob/master/yanksel/init.lua

local luakit = luakit
local modes = require "modes"
local add_binds = modes.add_binds
local add_cmds = modes.add_cmds

local actions = {
	copy = {
		desc = "Copy to clipboard.",
		func = function (w)
			local text = luakit.selection.primary
			local num_chars = string.len(text)
			local _, num_lines = text:gsub("\n", "%1")
			
			-- If nothing selected, then bork.
			if not text then w:error("Empty selection.") return end
			
			luakit.selection.clipboard = text
			w:notify(string.format("Copied %d line(s), %d char(s)", num_chars, num_lines))
			
			-- Deselect the selected text.
			luakit.selection.primary = ""
		end,
	}
}

add_binds("normal", {
	{"^c$", actions.copy }
})

add_cmds({
	{":copy", actions.copy }
})
			
			
			