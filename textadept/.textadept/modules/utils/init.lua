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
	This looks like it can be used to efficiently load all the dependencies of a given
widget or feature into one table, that 'init.lua' then uses to "compute"/define the
actual module/feature, which then gets exported to .textadept/init.lua.
	Right now, it just heaps a bunch of individual modules into one bundle, which
the top-level init then picks and chooses from.
	In other words, for now, it may well be suitable to only worry about having a 
flat module system. If you ever need to do a directory, use this approach as described
above.
]]