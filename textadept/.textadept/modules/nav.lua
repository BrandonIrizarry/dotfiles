local M = {}
local NAME = "Nav"

local nav_bindings = {
	h = function () buffer:char_left() end,
	j = function () buffer:line_down() end,
	k = function () buffer:line_up() end,
	l = function () buffer:char_right() end,
	cf = function () buffer:page_down() end,
	cb = function () buffer:page_up() end,
--	["\n"] = function () buffer:new_line() end,
}


-- The command entry itself is problematic, since that involves (afaik)
-- changing the key mode to something else. The mode isn't
-- set back the way it was; instead, it's set to a default one somewhere.
local colon = {
	b = ui.switch_buffer,
	o = io.open_file,
	u = function () io.quick_open(_USERHOME) end,
	r = function () io.quick_open(_HOME) end,
}

-- An example set of top-level bindings for a mode.
-- These don't respond to numeric prefixes.
local nav_rootb = {
	t = function () view:goto_buffer(1) end,
	T = function () view:goto_buffer(-1) end,
	[":"] = colon,
}

function M.load ()
	return define_mode(NAME, nav_bindings, true, nav_rootb)
end

return M