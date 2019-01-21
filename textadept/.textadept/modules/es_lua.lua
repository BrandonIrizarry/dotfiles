return {

  reload = 
[[
function reload ()
	package.loaded["%<buffer.filename>"] = nil
	dofile("%<buffer.filename>")
end
]],

  loc = "local %1(name)%2( = %3(buffer))%0",

  func = 
[[
function%1( %2(name)) (%3(args))
    %0
end
]],

  ["."] = "%1(lib).%0(member)",
  
  pr = "print(%0)",
} 