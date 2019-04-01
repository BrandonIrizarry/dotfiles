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
	-- "theming" has to be first, if we want to inspect module
	-- loading with 'ui.print', and not break things.
	
	-- Stateful; just requiring them is enough to activate what they do.
	"theming",  
	"misc_keys",
	"custom_cli_flags",
	
	-- Non-stateful; they return something that their eventual functionality
	-- will depend on.
	"alert", 
	"es_global", 
	"lua.repl2", 
	"misc_events",
	"lua-pattern-find",
	"paste_reindent",
	"file_browser",
	"search",
}

local data = {}

for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)
	
	-- This print statement tells me what modules return something
	-- other than 'true'.
	--ui.print(string.format("%-20s%30s", tostring(mod), tostring(result))) 

	
	-- We could, in some cases, just abort the entire config,
	-- to avoid some things loading and others not.
	if not status then 
		ui.print(result)
	else
		data[mod] = result
	end
end

-- Modules and global settings dependent on the lexer used.
events.connect(events.LEXER_LOADED, function(lexer)

	--[[
	function enclose (start_line, end_line)
		local buffer = buffer
		local start_pos = buffer.line_indent_position[start_line - 1]
		local end_pos = buffer.line_end_position[end_line - 1]
		
		-- Get the prefix and suffix of the current block-comment syntax.
		local comment = textadept.editing.comment_string[buffer:get_lexer(true)] or ''
		local prefix, suffix = comment:match('^([^|]+)|?([^|]*)$')

		-- If there is no comment string syntax defined for this lexer, then abort.
		if not prefix then return end
		
		-- Calculate the current level of indentation:
		-- How much preceding whitespace is there?
		local preceding = buffer:get_cur_line():match("^%s*")
		
		-- At this point, we have a prefix and suffix -
		-- comment out the specified block.
		buffer:begin_undo_action()
		buffer:insert_text(end_pos, "\n" .. preceding .. suffix)
		buffer:insert_text(start_pos, prefix .. "\n" .. preceding)
		buffer:end_undo_action()
	end
	--]]
	
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
		
		-- Should only take effect for multilines.
		--textadept.editing.comment_string.lua = "--[[|]]"
		
		--[===[
		keys.lua["c/"] = {
			["0"] = function ()
				textadept.editing.comment_string.lua = "--"
				textadept.editing.block_comment()
			end,
			
			["1"] = function ()
				textadept.editing.comment_string.lua = "--[[|]]"
				textadept.editing.block_comment()
			end,
			
			["2"] = function ()
				textadept.editing.comment_string.lua = "--[=[|]=]"
				textadept.editing.block_comment()
			end,
			
			["3"] = function ()
				textadept.editing.comment_string.lua = "--[==[|]==]"
				textadept.editing.block_comment()
			end,
		}
	]===]
	end
end)


-- GLOBAL STATE BASED ON MODULES

keys.cl = {} -- initialize ctrl+l for keychains.

-- Enhance the menu.
do
	local new_repl = data["lua.repl2"].new_repl
	table.insert(textadept.menu.menubar[_L['_Tools']], {''})
	table.insert(textadept.menu.menubar[_L['_Tools']], {'Lua REPL', new_repl})
end




-- Global snippets.
for shorthand, snippet in pairs(data.es_global) do
  snippets[shorthand] = snippet
end

-- FILE BROWSER
-- for now, use an inputbox, but may be better to 
-- use something like the command entry file opener,
-- but only look at directories.
do
	local fb = data.file_browser
	
	keys.cl.f = function ()
		local button, user_inputs = 
			ui.dialogs.inputbox {
				title = "File Browser",
				informative_text = {
					"Open a project",
					"Root directory",
					"Project name",
				},
				text = {os.getenv("HOME"), "PIL"},
			}
			
		
		-- Sanitize the prefix
		local prefix = io.open(tostring(user_inputs[1])) and user_inputs[1] or os.getenv("HOME")
		local directory = string.format("%s/%s", prefix, user_inputs[2])
		
		-- User hits "OK" and directory actually exists.
		local exists = io.open(directory)
		
		if button == 1 and exists then
			fb.init(directory)
		elseif button == 1 and not exists then
			data.alert(nil, "No valid directory specified.")
		end
	end
end

-- SEARCH
do
	local g = data.search.goto_nearest_occurrence
	keys.ck = function() g(false) end
	keys.cK = function() g(true) end
end

-- Keybindings.
keys["c#"] = data["lua.repl2"].new_repl
keys.cv = data.paste_reindent



-- Modules that depend on other modules, and therefore need an init method.
data.misc_events.init(data.alert)

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


