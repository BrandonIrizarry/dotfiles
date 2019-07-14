-- Load Youtube videos externally from Youtube, with MPV and youtube-dl.
-- Taken from https://github.com/luakit/luakit/wiki/Play-embedded-video-in-external-player 

local modes = require("modes")
local video_cmd_fmt = "mpv --ytdl '%s'"
modes.add_binds("ex-follow", {
  { "m", "Hint all links and open the video behind that link externally with MPV.",
      function (w)
          w:set_mode("follow", {
              prompt = "open with MPV", selector = "uri", evaluator = "uri",
              func = function (uri)
                  assert(type(uri) == "string")
                  luakit.spawn(string.format(video_cmd_fmt, uri))
                  w:notify("Launched MPV, please wait...")
              end
          })
      end },
  { "M", "Open the video on the current page externally with MPV.",
      function (w)
        local uri = string.gsub(w.view.uri or "", " ", "%%20")
        luakit.spawn(string.format(video_cmd_fmt, uri))
        w:notify("Launched MPV, please wait...")
      end },
})