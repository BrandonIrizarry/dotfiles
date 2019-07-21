RingBuffer = {}

function RingBuffer:new (max_size)
	local rb = {}
	
	rb.max_size = max_size
	rb.contents = {}
	
	self.__index = self
	setmetatable(rb, self)
	
	return rb
end

function RingBuffer:pop ()
	return table.remove(self.contents, 1)
end

function RingBuffer:push (item)
	table.insert(self.contents, item)
	local size = #self.contents
	
	if size > self.max_size then
		return self:pop()
	end
end
	
function RingBuffer:inspect ()
	return self.contents
end
	
return RingBuffer