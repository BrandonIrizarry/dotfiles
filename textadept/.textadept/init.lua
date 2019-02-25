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

--open_file_or_new = require("open_file_or_new").open_file_or_new
--keys.co = open_file_or_new
--keys.cu = function () open_file_or_new(_USERHOME .. "/") end

--textredux = require 'textredux'
--keys.co = textredux.fs.open_file
--keys.cu = function () keys.co(_USERHOME .. "/") end

if not CURSES then
	keys.f11 = reset
end

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
--[[
if not CURSES then
  for binding, func in pairs(require("extra_keys")) do
    keys[binding] = func
  end
end
--]]

-- Confirm saves with a dialog box.
events.connect(events.FILE_AFTER_SAVE, function (filename)
	local basename = filename:match("^.+/(.+)")
	alert(1, string.format("Wrote file '%s' to disk!", basename))
end)

-- Before resetting, save all open buffers to disk.
events.connect(events.RESET_BEFORE, function ()
  io.save_all_files()
end)


if CURSES then
    buffer:set_theme("term-bci")
else
	local FONT_TABLE = { font="Courier", fontsize = 15}
	local THEME	= "dark"

	buffer:set_theme(THEME, FONT_TABLE)
end

keys.cT = function () os.spawn("lxterminal", buffer.filename:match("^(.*)/")) end

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

-- Wrap long lines into view
--buffer.wrap_mode = buffer.WRAP_WHITESPACE

keys.f12 = function () os.spawn("textadept -f -u '/home/brandon/.textadept-blank'") end



function jump (line_no)
	buffer:goto_line(line_no - 1)
end

if CURSES then 
	keys.f2 = 
		function () ui.command_entry.enter_mode("lua_command", "lua") end 
end

--package.path = "/home/brandon/.textadept/textadept-vi/?.lua;" .. package.path
--package.cpath = "/home/brandon/.textadept/textadept-vi/?.so;" .. package.cpath

--_G.vi_mode = require "vi_mode"