local function parse (cmd_text)
	for word in cmd_text:gmatch("%g+") do
		ui.print(word)
	end
end

keys.parse = {
	["\n"] = function ()
		return ui.command_entry.finish_mode(parse) 
	end
}

keys["c_"] = function () ui.command_entry.enter_mode("parse") end