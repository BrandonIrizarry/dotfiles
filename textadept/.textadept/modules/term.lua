local function term ()
	local maybe_buffer = buffer.filename and buffer.filename:match("^.*/") or os.getenv("HOME")
	os.spawn("xterm", maybe_buffer)
end

return term