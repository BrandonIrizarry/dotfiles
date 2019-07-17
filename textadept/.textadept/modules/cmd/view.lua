

local view = {} -- view-specific commands

function view.split ()
	_G.view:split()
end

function view.vsplit ()
	_G.view:split(true)
end

function view.keep ()
	_G.view:unsplit()
end

function view.next ()
	ui.goto_view(1)
end

function view.prev ()
	ui.goto_view(-1)
end

function view.delete ()
	ui.goto_view(1)
	_G.view:unsplit()
end

function view.only ()
	while _G.view:unsplit() do
	end
end

return view