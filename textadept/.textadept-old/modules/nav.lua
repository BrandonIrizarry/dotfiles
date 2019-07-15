--- small navigation mode based on vi.
-- Only used for simple 'hjkl' navigation and saving.
-- For a full vi setup, look at [Chris vi](https://github.com/jugglerchris/textadept-vi)
-- @author [Alejandro Baez](https://twitter.com/a_baez)
-- @module nav

keys.command_mode = {
  ['h'] =
    function() buffer.char_left() end,
  ['j'] =
    function() buffer.line_down() end,
  ['k'] =
    function() buffer.line_up() end,
  ['l'] =
    function() buffer.char_right() end,
  ['i'] =
    function()
      keys.MODE = nil
      ui.statusbar_text = 'INSERT MODE'
    end,
  ['o'] =
    function()
      buffer:line_end(); buffer:new_line()
      keys.MODE = nil
      ui.statusbar_text = 'INSERT MODE'
    end,
  [":"] = {
	ui.command_entry.enter_mode("lua_command", "lua")
  },

  ['r'] =
    function()
      keys.MODE = nil
      textadept.editing.select_word()
    end,
  ['b'] =
    function() buffer.word_left() end,
  ['w'] =
    function() buffer.word_right() end,
}

keys['esc'] =
  function()
    keys.MODE = 'command_mode'
    ui.statusbar_text = "COMMAND MODE"
    if CURSES then return end
    buffer.caret_style = buffer.CARETSTYLE_BLOCK
  end

events.connect(events.UPDATE_UI, function()
  if keys.MODE == 'command_mode' then
    ui.statusbar_text = "COMMAND MODE"
  else
    ui.statusbar_text = 'INSERT MODE'
    if CURSES then return end
    buffer.caret_style = buffer.CARETSTYLE_LINE
  end
end)
