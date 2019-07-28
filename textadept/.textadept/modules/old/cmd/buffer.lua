local buffer = {} -- buffer/file related commands.

buffer.all = ui.switch_buffer
buffer.close = io.close_buffer
buffer.close_all = io.close_all_buffers
buffer.open = io.open_file
buffer.save = io.save_file
buffer.save_as = io.save_file_as

function buffer.next ()
	view:goto_buffer(1)
end

function buffer.prev ()
	view:goto_buffer(-1)
end

function buffer.create ()
	buffer:new()
end
	
return buffer
