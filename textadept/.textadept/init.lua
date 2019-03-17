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
	"args",
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