local Log = {}

function Log:new (filename)
	local mode = lfs.attributes(filename) and "a+" or "w"
	
	self.file = io.open(filename, mode)
	return self
end

function Log:log (fmt, good, ...)
	local wrt = string.format(fmt, ...)
	self.file:write(string.format("%s\n%s\n", os.date(), wrt))
	
	if not good then
		ui.statusbar_text = "An error occurred; see logfile."
	end
end

function Log:finish ()
	self.file:close()
end

return Log
	
	