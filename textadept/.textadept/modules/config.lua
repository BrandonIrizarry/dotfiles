local M = {}

function M.config ()
	io.quick_open(_USERHOME)
end

function M.root_config ()
	io.quick_open(_HOME)
end

return M