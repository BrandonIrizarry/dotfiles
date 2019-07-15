local modules = {
	"copy_paste",
}

local data = {}
local err_msg
	
for _, mod in ipairs(modules) do
	local status, result = pcall(require, mod)

	if status then
		data[mod] = result
	else
		data = {}
		err_msg = result
		break
	end
end

setmetatable(data, {__index = function ()
	ui.print("User modules haven't been loaded, due to the following error:")
	ui.print(err_msg)
end})

return data