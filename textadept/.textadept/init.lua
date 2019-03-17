--[[ As steals the morn upon the night,
and melts the shades away,
so Truth does Fancy's charm dissolve,
and rising Reason puts to flight
the fumes that did the mind involve,
restoring intellectual day.

from L'Allegro, il Penseroso ed il Moderato
Charles Jennens and George Frideric Handel (1685-1759)
]]  


local modules = {
	"alert", 
	"theming", 
	"es_global", 
	"lua.repl2", 
	"custom_cli_flags",
	"misc_events",
	"misc_keys",
	"lua-pattern-find"}

local data = {}

for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)
	
	if not status then 
		ui.print(result) 
	else
		data[mod] = result
	end
end

-- Set global state from the modules:

-- The function 'alert'.
alert = data.alert.alert

-- Global snippets.
for shorthand, snippet in pairs(data.es_global) do
  snippets[shorthand] = snippet
end

-- Custom CLI flags for Textadept (--wait, etc.)
data.custom_cli_flags.init()


-- Rename the file based on the current buffer, in place.
function rename_in_place (new_name)

	-- If buffer doesn't point to a file, then don't do anything.
	if not buffer.filename then return end
	
	-- Prepare for file manipulation.
	local filename = buffer.filename
	local full_name = filename:match("^.*/") .. new_name
	
	-- Only operate on stuff on disk; don't rely on any of
	-- Textadept's live state.
	-- It's easier to close and reopen a buffer, rather than mess with 
	-- the _BUFFERS table.
	io.close_buffer()
	assert(os.rename(filename, full_name))
	io.open_file(full_name)
end
	