

local _V = {} -- view-specific commands

function _V.hsplit ()
	view:split()
	
end

function _V.vsplit ()
	view:split(true)
end

function _V.unsplit ()
	view:unsplit()
end

function _V.next ()
	ui.goto_view(1)
end

function _V.close ()
	ui.goto_view(1)
	view:unsplit()
end

function _V.only ()
	while view:unsplit() do
	end
end

return _V