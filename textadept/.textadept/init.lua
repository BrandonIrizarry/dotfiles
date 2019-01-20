--[[ As steals the morn upon the night,
and melts the shades away,
so Truth does Fancy's charm dissolve,
and rising Reason puts to flight
the fumes that did the mind involve,
restoring intellectual day.

from L'Allegro, il Penseroso ed il Moderato
Charles Jennens and George Frideric Handel (1685-1759)
]]  

-- When calling this function, make sure the timeout in seconds is the first argument!
alert = require("alert").alert 

if not CURSES then
  rgb_dialog = require("rgb_dialog").dialog
end

-- Load extra snippets to the Lua snippets table.
for shorthand, snippet in pairs(require("es_lua")) do
  snippets.lua[shorthand] = snippet
end

-- Load my personal global snippets into Textadept.
for shorthand, snippet in pairs(require("es_global")) do
  snippets[shorthand] = snippet
end

-- Load extra/personal keybindings into Textadept.
if not CURSES then
  for binding, func in pairs(require("extra_keys")) do
    keys[binding] = func
  end
end

-- Confirm saves with a dialog box.
events.connect(events.FILE_BEFORE_SAVE, function ()
  alert(1, "Wrote file to disk!")
end)

if CURSES then
    buffer:set_theme("term")
else
	local FONT_TABLE = {font = "Inconsolata", fontsize = 15}
	local THEME = "dark"

	buffer:set_theme(THEME, FONT_TABLE)
end

keys.cT = function () os.spawn("desktop-defaults-run -t", string.match(buffer.filename, "^(.+)/")) end