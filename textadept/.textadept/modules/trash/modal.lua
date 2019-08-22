

local exclusion = {__index = function (kt, key)
	if tonumber(key) then
		--return kt[key]
	end
	
	ui.statusbar_text = string.format("Key isn't bound in this mode: %s", key)
end}

local modal = setmetatable({}, exclusion)

-- 'mobj' can be a mapping from bindings to actions,
-- or a metatable specifying how to react to a certain
-- class of bindings (e.g. numerals).
function modal:new (mobj)

	-- if 'mobj' is a metatable by design, then don't overwrite its __index field!
	if not self.__index then
		self.__index = self
	end
	
	setmetatable(mobj, self)
	return mobj
end

return modal
	
	
	


	

