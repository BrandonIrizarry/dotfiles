Ring = {}

function Ring:new (max_size) -- 'contents' is a table
	local ring = {}
	
	ring.max_size = max_size
	ring.contents = {}
	
	self.__index = self
	setmetatable(ring, self)
	
	return ring
end

function Ring:add (item)
	table.insert(self.contents, item)
	local size = #self.contents
	
	if size > self.max_size then
		table.remove(self.contents, 1)
	end
end
	
return Ring