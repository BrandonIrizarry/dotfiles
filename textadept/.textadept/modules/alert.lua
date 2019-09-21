return function (...)
    local args = table.pack(...)
    
    for i=1, args.n do
      args[i] = tostring(args[i])
    end
    
    ui.dialogs.msgbox {
      title = "Alert!",
      text = table.concat(args, " "),
    }
end

