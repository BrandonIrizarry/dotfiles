--[[
	Modulo hidden bugs, done. But some thoughts:
	
	With small changes in the code, would it help to practice _this_:
	
	local lm = launch_menu:clone(path) -- "launch_menu" is the primordial ancestor of all such menus
	lm.sort = function () _your code here_ end -- this particular module uses a subgenus of l.m.
	
	lm3 = lm2:clone(path) -- here each call uses a grandchild of l.m.
	lm3:launch()
	
	We're very close to this, just put it in for now as we have it :)
	
	You'd think that 'title' should also me one of those "milestone" fields in the 
	inheritance chain, like 'sort'... for now, it's ok, though.
]]

local M = {}

local function strip (entry)
	local pos = entry:find("[*/=>@|]")
	if pos then 
		return entry:sub(1, pos - 1), entry:sub(pos, pos)
	else
		return entry
	end
end

function M.init ()
	
	local sort = function (w1, w2)
		w1, w2 = strip(w1), strip(w2)
		return w1 < w2
	end
	
	local function dir_set (path)
		local set = {}
		
		local ls_handle = io.popen("ls -aLF "..path)
		
		for entry in ls_handle:lines() do
			local base, suffix = strip(entry)
			
			if entry == "./" then
				set[entry] = function ()
					local button, input = ui.dialogs.inputbox {
						title = "New File or Directory",
						width = 300
					}
				
					if button == 1 and input then
						local suffix = input:sub(#input)
						local new_path = path..input
						
						if suffix == "/" then
							lfs.mkdir(path..input)
							local lm = launch_menu.init(new_path, sort)
							lm(dir_set(new_path))
						else
							if io.open(new_path) then
								alert("File already exists!")
							else
								local f = io.open(new_path, "w")
								f:close()
								io.open_file(new_path)
							end
						end
					else
						local lm = launch_menu.init(path, sort)
						lm(dir_set(path))
					end
				end
			elseif suffix == "/" then
				set[entry] = function ()
					local new_path
					if base == "." then
						new_path = path
					elseif base == ".." then -- going up!
						new_path = path:sub(1,#path-1):match("^.*/") or "/"
					else
						new_path = path..entry
					end
						local lm = launch_menu.init(new_path, sort)
						lm(dir_set(new_path))
				end
			else
				set[base] = function () io.open_file(path..base) end
			end
		end
		
		return set
	end
	
	local path = os.getenv("HOME").."/"
	local lm = launch_menu.init(path, sort)
	
	lm(dir_set(path))
end

return M