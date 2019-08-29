local M = {}
local NAME = "God Mode"

local gbinds = {
	c = function () ui.command_entry("lua_command", "lua") end,
	h = textadept.editing.show_documentation,
	b = ui.switch_buffer,
	j = textadept.editing.goto_line,
	n = function () view:goto_buffer(1) end,
	p = function () view:goto_buffer(-1) end,
	["="] = buffer.zoom_in,
	["-"] = buffer.zoom_out,
	["0"] = function () buffer.zoom = 0 end,
	u = buffer.page_up,
	d = buffer.page_down,
}

local bindings = {
	n = function () buffer:line_down() end,
	p = function () buffer:line_up() end,
	f = function () buffer:char_right() end,
	b = function () buffer:char_left() end,
	a = function () buffer:home() end,
	e = function () buffer:line_end() end,
	cg = buffer.cancel,
	o = io.open_file,
	w = io.close_buffer,
	q = quit,
	g = gbinds,
}

function M.load()
	return define_mode(NAME, bindings, false)
end

return M