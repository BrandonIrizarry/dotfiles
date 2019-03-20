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
	"lua-pattern-find",
	"paste_reindent"}

local data = {}

for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)
	
	if not status then 
		ui.print(result) 
	else
		data[mod] = result
	end
end

-- Modules and global settings dependent on the lexer used.
events.connect(events.LEXER_LOADED, function(lexer)

	-- Lua lexer definitions.
	if lexer == 'lua' then 
		
		local TA_REPL = data["lua.repl2"]
		if TA_REPL then
			keys.lua.cj = 
				function()
					if buffer._type ~= '[Lua REPL]' then 
					return false end -- propagate keypress to global keybinds.
					TA_REPL.evaluate_repl()
				end
		end
	end
end)


-- Set global state from the modules:

-- Keybindings.
keys["c#"] = data["lua.repl2"].new_repl
keys.cv = data.paste_reindent

-- The function 'alert'.
alert = data.alert.alert

-- Global snippets.
for shorthand, snippet in pairs(data.es_global) do
  snippets[shorthand] = snippet
end

-- Modules that use an init method
-- Custom CLI flags for Textadept (--wait, etc.)
data.custom_cli_flags.init()
data.misc_events.init(alert)

-- Enhance the menu.
table.insert(textadept.menu.menubar[_L['_Tools']], {''})
table.insert(textadept.menu.menubar[_L['_Tools']], {'Lua REPL', new_repl})


-- FUNCTIONS TO BE ADDED/PLACED INTO MODULES.

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

function goto_nearest_occurrence(reverse)

        local s = buffer.selection_start
		local e = buffer.selection_end
		
        if s == e then
                s = buffer:word_start_position(s)
				e = buffer:word_end_position(s)
        end
		
		-- Define our word to be searched for.
        local word = buffer:text_range(s, e)
		
		-- No word is detected under cursor.
        if word == '' then return end
		
		-- Search how we come across words.
        --buffer.search_flags = buffer.FIND_WHOLEWORD + buffer.FIND_MATCHCASE
		-- Ideally, we'd use Lua patterns or a regexp at this point, 
		-- occasionally specifying if we want the search to be literal.
		buffer.search_flags = buffer.FIND_MATCHCASE
		
        if reverse then
				-- Search from just before beginning of the current occurrence,
				-- to beginning of the buffer.
                buffer.target_start = s - 1
                buffer.target_end = 0
        else
				-- Search from just after the end of the current occurrence,
				-- to the end of the buffer.
                buffer.target_start = e + 1
                buffer.target_end = buffer.length
        end
		
		-- Wrap the search if the word wasn't found.
		-- Perform the inverse action of either respective search.
        if buffer:search_in_target(word) == -1 then
                if reverse then
                        buffer.target_start = buffer.length
                        buffer.target_end = e + 1
                else
						
                        buffer.target_start = 0
                        buffer.target_end = s - 1
                end
				
				-- Word still not found, oh well.
                if buffer:search_in_target(word) == -1 then return end
        end
		
		-- 'search_in_target' was successful, so these two quantities are set.
		-- Therefore, set the selection based on them; have them define the
		-- selection, and Jake's your uncle.
        buffer:set_sel(buffer.target_start, buffer.target_end)
end

keys.ck = function() goto_nearest_occurrence(false) end
keys.cK = function() goto_nearest_occurrence(true) end