-- The all-important 'alert'.
return function (...)
    local args = table.pack(...)
    
    for i=1, args.n do
      args[i] = tostring(args[i])
    end
    
    local data = table.concat(args, "\n")
    
    ui.dialogs.msgbox {
      title = "Alert!",
      text = data,
    }
end
