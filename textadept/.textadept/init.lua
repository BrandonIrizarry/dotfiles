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

keys.co = require("open_file_or_new").open_file_or_new


-- Load extra snippets to the Lua snippets table; 
-- make sure that the Lua lexer is loaded _first_.
events.connect(events.LEXER_LOADED, function (lexer)
  if lexer == "lua" then
    for shorthand, snippet in pairs(require("es_lua")) do
      snippets.lua[shorthand] = snippet
    end
  end
end)

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
events.connect(events.FILE_BEFORE_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	alert(1, string.format("Wrote file '%s' to disk!", basename))
end)

-- Before resetting, save all open buffers to disk.
events.connect(events.RESET_BEFORE, function ()
  io.save_all_files()
end)


if CURSES then
    buffer:set_theme("term")
else
	local FONT_TABLE = {font = "Inconsolata", fontsize = 15}
	local THEME = "dark"

	buffer:set_theme(THEME, FONT_TABLE)
end

keys.cT = function () os.spawn("desktop-defaults-run -t", buffer.filename:match("^(.*)/")) end

-- Disable character autopairing with typeover
textadept.editing.auto_pairs = nil
textadept.editing.typeover_chars = nil

-- Always use tabs of width 4 for indentation.
buffer.use_tabs = true
buffer.tab_width = 4

-- Disable indentation guides
buffer.indentation_guides = buffer.IV_NONE

-- Disable code folding and hide the fold margin
buffer.property.fold = "0"
buffer.margin_width_n[2] = 0
