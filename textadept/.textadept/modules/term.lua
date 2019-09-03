-- DRY - determine the distro only on Lua reset.
local distro = "other"

local info = io.popen("inxi -S"):read("a")
	
if info:find("antiX") then
	distro = "antiX"
end	

local function term ()
	local maybe_buffer = buffer.filename and buffer.filename:match("^.*/") or os.getenv("HOME")
	
	if distro == "antiX" then
		os.spawn("desktop-defaults-run -t", maybe_buffer)
		return
	end
	
	os.spawn("xterm", maybe_buffer)
end

return term