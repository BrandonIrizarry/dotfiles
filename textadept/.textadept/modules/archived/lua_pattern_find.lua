---
-- Module that brings back Textadept's Lua pattern searches and toggles between
-- them and regular expression searches.
-- Inserts a toggle option into the "Search" menu. You can also bind a key to
-- the `toggle_lua_patterns()` function.
-- Background: starting in Textadept 9.0 alpha 2, regular expression searches
-- replaced Lua pattern searches.
local M = {}

local lua_patterns = false -- utility flag toggled by `M.toggle_lua_patterns()`
local captures -- stores Lua pattern captures for replacements

local escapes = {
  ['\\a'] = '\a', ['\\b'] = '\b', ['\\f'] = '\f', ['\\n'] = '\n',
  ['\\r'] = '\r', ['\\t'] = '\t', ['\\v'] = '\v', ['\\\\'] = '\\'
}
for k, v in pairs(escapes) do escapes[v] = k end

-- Finds and selects text in the current buffer.
-- @param text The Lua pattern to find.
-- @param next Flag indicating whether or not the search direction is forward.
-- @param no_wrap Flag indicating whether or not the search will not wrap.
-- @param wrapped Utility flag indicating whether or not the search has wrapped
--   for displaying useful statusbar information. This flag is used and set
--   internally, and should not be set otherwise.
-- @return true, position of the found text or `-1`
local function lua_pattern_find(text, next, nowrap, wrapped)
  if text == '' or not ui.find.regex then return end
  if ui.find.in_files then ui.find.in_files = false end -- not supported

  local first_visible_line = buffer.first_visible_line -- for 'no results found'

  -- If text is selected, assume it is from the current search and increment the
  -- caret appropriately for the next search.
  if not buffer.selection_empty then
    local pos = buffer[next and 'current_pos' or 'anchor']
    buffer:goto_pos(buffer:position_relative(pos, next and 1 or -1))
  end

  -- Lua pattern search.
  local s = next and buffer.current_pos or 0
  local e = next and buffer.length or buffer.current_pos
  local patt = text:gsub('\\[abfnrtv\\]', escapes)
  if not next then patt = '^.*()'..patt end
  local caps = {buffer:text_range(s, e):find(patt)}
  captures = {table.unpack(caps, next and 3 or 4)}
  if #caps > 0 and caps[2] >= caps[1] then
    pos, e = s + caps[next and 1 or 3] - 1, s + caps[2]
    captures[0] = buffer:text_range(pos, e)
    buffer:set_sel(e, pos)
  end

  buffer:scroll_range(buffer.anchor, buffer.current_pos)

  -- If nothing was found, wrap the search.
  if pos == -1 and not no_wrap then
    local anchor = buffer.anchor
    buffer:goto_pos(next and 0 or buffer.length)
    ui.statusbar_text = _L['Search wrapped']
    events.emit(events.FIND_WRAPPED)
    pos = select(2, lua_pattern_find(text, next, true, true))
    if pos == -1 then
      ui.statusbar_text = _L['No results found']
      buffer:line_scroll(0, first_visible_line - buffer.first_visible_line)
      buffer:goto_pos(anchor)
    end
  elseif not wrapped then
    ui.statusbar_text = ''
  end

  return true, pos -- `true` for halting events.FIND propagation
end

-- Replaces found text.
-- `lua_pattern_find()` is called first, to select any found text. The selected
-- text is then replaced by the specified replacement text.
-- This function ignores "Find in Files".
-- @param rtext The text to replace found text with. It can contain both Lua
--   capture items (`%n` where 1 <= `n` <= 9) for Lua pattern searches and `%()`
--   sequences for embedding Lua code for any search.
-- @see lua_pattern_find
local function lua_pattern_replace(rtext)
  if buffer.selection_empty or not ui.find.regex then return end
  if ui.find.in_files then ui.find.in_files = false end
  buffer:target_from_selection()
  rtext = rtext:gsub('\\[abfnrtv\\]', escapes):gsub('%%%%', '\\037')
  if captures then
    for i = 0, #captures do
      rtext = rtext:gsub('%%'..i, (captures[i]:gsub('%%', '%%%%')))
    end
  end
  local ok
  ok, rtext = pcall(string.gsub, rtext, '%%(%b())', function(code)
    code = code:gsub('[\a\b\f\n\r\t\v\\]', escapes)
    local result = assert(load('return '..code))()
    return tostring(result):gsub('\\[abfnrtv\\]', escapes)
  end)
  if ok then
    buffer:replace_target(rtext:gsub('\\037', '%%'))
    buffer:goto_pos(buffer.target_end) -- 'find' text after this replacement
  else
    ui.dialogs.msgbox{
      title = 'Error', text = 'An error occured:',
      informative_text = rtext:match(':1:(.+)$') or rtext:match(':%d+:(.+)$'),
      icon = 'gtk-dialog-error'
    }
    -- Since find is called after replace returns, have it 'find' the current
    -- text again, rather than the next occurance so the user can fix the error.
    buffer:goto_pos(buffer.current_pos)
  end
end

local INDIC_REPLACE = _SCINTILLA.next_indic_number()
-- Replaces all found text.
-- If any text is selected, all found text in that selection is replaced.
-- This function ignores "Find in Files".
-- @param ftext The Lua pattern to find.
-- @param rtext The text to replace found text with.
-- @see find
local function lua_pattern_replace_all(ftext, rtext)
  if ftext == '' or not ui.find.regex then return end
  if ui.find.in_files then ui.find.in_files = false end
  buffer:begin_undo_action()
  local count = 0
  if buffer.selection_empty then
    buffer:goto_pos(0)
    while select(2, lua_pattern_find(ftext, true, true)) ~= -1 do
      lua_pattern_replace(rtext)
      count = count + 1
    end
  else
    local s, e = buffer.selection_start, buffer.selection_end
    buffer.indicator_current = INDIC_REPLACE
    buffer:indicator_fill_range(e, 1)
    buffer:goto_pos(s)
    local pos = select(2, lua_pattern_find(ftext, true, true))
    while pos ~= -1 and pos < buffer:indicator_end(INDIC_REPLACE, s) do
      lua_pattern_replace(rtext)
      count = count + 1
      pos = select(2, lua_pattern_find(ftext, true, true))
    end
    e = buffer:indicator_end(INDIC_REPLACE, s)
    buffer:set_sel(s, e > 0 and e or buffer.length)
    buffer:indicator_clear_range(e, 1)
  end
  ui.statusbar_text = string.format('%d %s', count, _L['replacement(s) made'])
  buffer:end_undo_action()
end

---
-- Toggles between Lua pattern searches and regular expression searches.
function M.toggle_lua_patterns()
  if not lua_patterns then
    events.connect(events.FIND, lua_pattern_find, 1)
    events.connect(events.REPLACE, lua_pattern_replace, 1)
    events.connect(events.REPLACE_ALL, lua_pattern_replace_all, 1)
    ui.find.regex_label_text = not CURSES and '_Lua pattern' or 'Pattern(F3)'
    local search = textadept.menu.menubar[_L['_Search']]
    search['Toggle _Lua patterns'][1] = 'Toggle Rege_x patterns'
  else
    events.disconnect(events.FIND, lua_pattern_find)
    events.disconnect(events.REPLACE, lua_pattern_replace)
    events.disconnect(events.REPLACE_ALL, lua_pattern_replace_all)
    ui.find.regex_label_text = not CURSES and _L['Rege_x'] or _L['Regex(F3)']
    local search = textadept.menu.menubar[_L['_Search']]
    search['Toggle Rege_x patterns'][1] = 'Toggle _Lua patterns'
  end
  lua_patterns = not lua_patterns
end

-- Append toggle option to the end of the "Search" menu's first block.
local search = textadept.menu.menubar[_L['_Search']]
for i = 1, #search do
  if search[i][1] == '' then -- separator
    table.insert(search, i, {'Toggle _Lua patterns', M.toggle_lua_patterns})
    break
  end
end

return M
