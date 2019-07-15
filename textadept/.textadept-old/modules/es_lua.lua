return {

  reload = 
[[
function reload ()
	package.loaded["%<buffer.filename>"] = nil
	dofile("%<buffer.filename>")
end
]],

 ["local"] = "local %1(name)%2( = %3(value))",

  ["function"] = 
[[
function%1( %2(name)) (%3(args))
    %0
end
]],

  ["."] = "%1(lib).%0(member)",
  
  ["print"] = "print(%0)",
  
  -- won't enter %2-snippet if there's no space i.e. if not written as '( %2' ...
  -- 'for %1' needs the space, because 'for' is a snippet!
  forp = 'for %1( %2(k),)%3(v) in pairs(%4(t)) do\n\t%0\nend',
}
