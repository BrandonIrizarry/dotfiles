-- My Luakit configuration file.

-- Adapted the "yanksel" plugin from
-- https://github.com/luakit/luakit-plugins/blob/master/yanksel/init.lua

local luakit = luakit
local modes = require "modes"
local add_binds = modes.add_binds
local add_cmds = modes.add_cmds

-- If I wanted to export this as a module, I'd use this.
-- local _M = {}

function find_num_lines (str)
   local found_newline = string.find(str, "\n")
   if not found_newline then return 1
   else
      return find_num_lines(string.sub(str, found_newline + 1)) + 1
   end
end

local actions = {
   yank_select = {
      desc = "Yank selection.",
      func = function (w)
         local text = luakit.selection.primary
         local message_chars = string.format(" %d characters", string.len(text))
         local num_lines = find_num_lines(text)
         local line_or_lines = ""

         if num_lines == 1 then
            line_or_lines = " line"
         else
            line_or_lines = " lines"
         end

         local message_lines = string.format(" %d", num_lines) .. line_or_lines

         if not text then w:error("Empty selection.") return end
         luakit.selection.clipboard = text
         w:notify("Yanked" .. message_lines .. "," .. message_chars)
         luakit.selection.primary = ""
      end,
   }
}

add_binds("normal", {{ "^c$", actions.yank_select }})


add_cmds({{ ":yanksel", actions.yank_select },})

-- exporting the actual module, if I should ever separate this out.
-- return _M


local follow = require("follow")

follow.stylesheet = [===[
#luakit_select_overlay {
    position: absolute;
    left: 0;
    top: 0;
    z-index: 2147483647; /* Maximum allowable on WebKit */
}

#luakit_select_overlay .hint_overlay {
    display: block;
    position: absolute;
    background-color: #000099;
    border: 1px dotted #000;
    opacity: 0.3;
}

#luakit_select_overlay .hint_label {
    display: block;
    position: absolute;
    background-color: white;
    border: 1px solid black;
    color: black;
    font-size: 18px;
    font-weight: bold;
    font-family: monospace, courier, sans-serif;
    opacity: 0.8;
}

#luakit_select_overlay .hint_selected {
    background-color: #00ff00 !important;
}
]===]


local select = require("select")

-- My added bindings
local modes = require("modes")
modes.add_binds("normal", {
                   {"h", "Open history", function (w) w:run_cmd(":history") end },
                   {"b", "Open bookmarks", function (w) w:run_cmd(":bookmarks") end},
                   {"J", "Go to previous tab", function (w) w:prev_tab() end},
                   {"K", "Go to next tab", function (w) w:next_tab() end},
})


