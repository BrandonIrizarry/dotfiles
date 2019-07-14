-- Copy selected text from browser window in normal mode using "c".    
require("copy")

-- Make the follow-boxes bigger.
local follow = require("follow")
local styles_dir = string.format("%s/styles/", luakit.data_dir)
follow.stylesheet = io.open(styles_dir .. "follow_stylesheet.css"):read("*a")

-- My added bindings
local modes = require("modes")

-- Require a homemade mpv module (in the user config directory, not the root one)
-- Taken from https://github.com/luakit/luakit/wiki/Play-embedded-video-in-external-player
local mpv = require("mpv")

modes.add_binds("normal", {
                   {"h", "Open history", function (w) w:run_cmd(":history") end },
                   {"b", "Open bookmarks", function (w) w:run_cmd(":bookmarks") end},
                   {"J", "Go to previous tab", function (w) w:prev_tab() end},
                   {"K", "Go to next tab", function (w) w:next_tab() end},
})


