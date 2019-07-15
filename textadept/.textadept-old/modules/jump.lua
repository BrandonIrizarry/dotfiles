
--[[ Good to visualize like this:
I want to add 'line 6', but we have it already.

4 3 6
_ _ _ 
	^
	| -- #self; prev == 6
	
Now, add 'line 7'.
1 3 8
_ _ _
	^
	| -- #self; prev == 8
	
7 ~= 8 so:

1 3 8 7
_ _ _ _
	^
	| -- table.insert(self, 7) ...
	
1 3 8 7
_ _ _ _
	  ^
	  | -- self.pointer + 1
]]

local line_stack = {pointer = 0}

-- Let's try the trick from PIL 4, p. 220.
-- Import Section:
-- declare everything this module needs from outside
local alert = _C.alert
local buffer, ui, keys, _L = buffer, ui, keys, _L
local table, ipairs = table, ipairs
local load, type, math =  load, type, math

-- Close access to external objects.
_ENV = nil

-- NB: 'push' et al. are values inside a table; you can't make them "local".
function line_stack:push (line_number)
	self.pointer = #self
	local prev = self[self.pointer]
	
	if line_number ~= prev then
		table.insert(self, line_number)
		self.pointer = self.pointer + 1
	end
end

function line_stack:back ()
	if self.pointer == 0 then
		return false
	end
	
	if self.pointer == 1 then 
		self.pointer = #self -- wrap
		ui.statusbar_text = "Jump ring wrapped to end"
		return self[self.pointer]
	end
	
	self.pointer = self.pointer - 1 -- move pointer to the jump before that
	
	-- return to use in _C.back
	return self[self.pointer]
end

function line_stack:forward ()

	if self.pointer == 0 then
		return false
	end
	
	if self.pointer == #self then 
		self.pointer = 1 -- wrap
		ui.statusbar_text = "Jump ring wrapped to beginning"
		return self[self.pointer]
	end
	
	self.pointer = self.pointer + 1 -- move pointer to the next jump in the history
	
	return self[self.pointer] -- return to use in _C.forward
end


function line_stack:clear ()
	for index in ipairs(self) do
		self[index] = nil
	end
	
	self.pointer = 0
end


function keys.left ()
	local back = line_stack:back()
	
	if not back then 
		alert("No jump history")
		return
	end
	
	back = back - 1
	buffer:ensure_visible_enforce_policy(back)
	buffer:goto_line(back)
end

function keys.right ()
	local forward = line_stack:forward()
	
	if not forward then
		alert("No jump history")
		return
	end
	
	forward = forward - 1
	buffer:ensure_visible_enforce_policy(forward)
	buffer:goto_line(forward)
end



-- Use a custom goto_line function.
function keys.cj (line)
	
	local current_line = buffer:line_from_position(buffer.current_pos) + 1
	local last_line = buffer.line_count
	
	-- Save the current position, so that we can go back.
	line_stack:push(current_line)
	
	if not line then
		local button, value = ui.dialogs.inputbox {
			title = _L["Go To"],
			informative_text = _L["Line Number:"] .. " ",
			button1 = _L["_OK"],
			button2 = _L["_Cancel"],
		}
	
		if button ~= 1 or not value then return end
		line = value -- export 'value' outside this scope!
	end
		
	-- Begin parsing the line/input.
	-- Use '@' as an alias for the current line, and '$' for the last line.
	-- e.g. "@ - 10" moves back ten lines, "@ + 3" moves forward three.
	-- + 1, because we're using the "wrong" (human readable) line-numbering system.
	line = line:gsub("@", current_line)
	line = line:gsub("%$", last_line)
	
	-- Handle arithmetic expressions
	-- You can use 'math.huge' to move to the end, and open a new line there.
	-- You can use '$' to simply go to the last line.
	-- Only let 'math' be accessible from the default global environment :)
	line = load("return " .. line, "jump user input", "t", {math = math})()
	if type(line) ~= "number" then return end -- sanity-check the input.
		
	if line >= last_line + 1 then
		buffer:ensure_visible_enforce_policy(last_line - 1)
		buffer:goto_line(last_line - 1)
		buffer:line_end()
		buffer.new_line()
		line_stack:push(last_line)
	else
		line_stack:push(line)
		line = line - 1
		buffer:ensure_visible_enforce_policy(line)
		buffer:goto_line(line)
	end
end