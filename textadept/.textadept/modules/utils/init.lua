--[[
/home/brandon/.textadept/?.lua
/home/brandon/.textadept/modules/?.lua 
/home/brandon/.textadept/modules/?/init.lua
--]]

local M = {} -- the 'utils' module

function load_utils (filename)
    local util = filename:match("^.*/([^.]+)")
    M[util] = require("utils." .. util)
end

lfs.dir_foreach(_USERHOME .. "/modules/utils/", load_utils, {".lua", "!init.lua"}, 0)

return M
  
--[[
	This just heaps a bunch of individual modules into one bundle, by filename.
]]

