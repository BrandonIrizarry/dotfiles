--[[
  An alert function for displaying user messages.
  Note that you must pass in the timeout in seconds,
  as the first argument.
  
  Good also for inspecting data.
]]

return { 
  alert = function (timeout, ...)
    local data = table.concat({...}, "\n")
    
    ui.dialogs.msgbox {
      title = "Alert!",
      text = data,
      timeout = timeout,
    }
  end,
}