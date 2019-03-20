
local M = {}

function M.init (alert)
	-- Confirm saves with a dialog box.
	events.connect(events.FILE_AFTER_SAVE, function (filename)
		local basename = filename:match("^.+/(.+)")
		alert(1, string.format("Wrote file '%s' to disk!", basename))
	end)

	-- Before resetting, save all open buffers to disk.
	events.connect(events.RESET_BEFORE, function ()
	  io.save_all_files()
	end)

	-- For now, this is our way of making the Message Buffer not prompt for a save
	-- Might have to be KEYPRESS.
	events.connect(events.UPDATE_UI, function (x)
		if buffer._type == "[Message Buffer]" then
			buffer:set_save_point()
		end
	end)
end

return M