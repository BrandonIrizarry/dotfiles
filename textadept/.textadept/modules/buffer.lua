local _B = {} -- buffer/file related commands.

_B.all = ui.switch_buffer
_B.close = io.close_buffer
_B.close_all = io.close_all_buffers
_B.open = io.open_file
_B.save = io.save_file
_B.save_as = io.save_file_as

function _B.config ()
	io.quick_open(_USERHOME)
end

function _B.root_config ()
	io.quick_open(_HOME)
end

function _B.next ()
	view:goto_buffer(1)
end

function _B.prev ()
	view:goto_buffer(-1)
end

function _B.new ()
	buffer:new()
end
	
return _B
