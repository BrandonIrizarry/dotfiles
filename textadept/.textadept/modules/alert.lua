--[[
  An alert function for displaying user messages.
  Note that you must pass in the timeout in seconds,
  as the first argument.
  
  Good also for inspecting data.
]]

return function (timeout, ...)
    local args = table.pack(...)
    
    for i=1, args.n do
      args[i] = tostring(args[i])
    end
    
    local data = table.concat(args, "\n")
    
    ui.dialogs.msgbox {
      title = "Alert!",
      text = data,
      timeout = timeout,
    }
end