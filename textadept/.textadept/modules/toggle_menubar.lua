local menubar = textadept.menu.menubar
switch = true

return function ()
	if switch then
		textadept.menu.menubar = nil
		switch = false
		return
	end
	
	textadept.menu.menubar = menubar
	switch = true
end
	