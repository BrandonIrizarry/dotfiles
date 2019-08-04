


local M = {}

local m = {
		Open = io.open_file,
		New = function () buffer:new() end,
		Rename = rename_file,
		Save = io.save_file,
		Close = io.close_buffer,
		Quit = quit,
}

local reverse_order = function (a,b) return a > b end
	
function M.run_tests ()
	
	
	local in_order = "In Order"
	local reversed = "Reversed"
	
	local lm = launch_menu.init()
	
	lm:launch(m, in_order)
	lm.sort = function (a,b) return a > b end
	lm:launch(m, reversed) -- reversed
	lm2 = lm:clone()
	lm2:launch(m, reversed) -- reversed
	--lm3 = require "launch_menu" --try getting a fresh copy
	--lm3:launch(m, reversed) -- still reversed
	lm4 = launch_menu.init() -- make a fresh copy
	lm4:launch(m, in_order) -- should be in order
end

function M.run_proxy()
	--launch_menu.sort = nil
	launch_menu:launch(m)
	lm2 = launch_menu:clone()
	--lm2:launch(m)
	lm2.sort = reverse_order
	lm2:launch(m)
	--launch_menu:launch(m)
	--launch_menu.sort = reverse_order
	lm3 = launch_menu:clone()
	lm3:launch(m)
end

return M