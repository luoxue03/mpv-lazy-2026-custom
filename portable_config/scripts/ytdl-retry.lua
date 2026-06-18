-- ytdl-retry.lua: auto-retry when yt-dlp extraction fails (e.g. SpankBang 403)
-- Place in portable_config/scripts/

local mp = require("mp")
local msg = require("mp.msg")

local max_retries = 8
local retry_delay = 2  -- seconds between retries
local retry_count = 0
local current_path = nil

-- Only retry URLs that go through yt-dlp (http/https, not direct media files)
local function is_ytdl_url(path)
    if not path then return false end
    if not path:match("^https?://") then return false end
    -- Skip direct media file URLs
    local ext = path:match("%.(%w+)$")
    if ext then
        local media_exts = {
            mp4=1, mkv=1, webm=1, avi=1, flv=1, ts=1,
            mp3=1, m4a=1, flac=1, wav=1, ogg=1,
            m3u8=1, mpd=1,
        }
        if media_exts[ext:lower()] then return false end
    end
    return true
end

local function on_start_file()
    local path = mp.get_property("path")
    if path ~= current_path then
        current_path = path
        retry_count = 0
    end
end

local function on_end_file(event)
    if event.reason ~= "error" then return end
    if not is_ytdl_url(current_path) then return end
    if retry_count >= max_retries then
        msg.warn("ytdl-retry: gave up after " .. max_retries .. " retries for: " .. current_path)
        return
    end

    retry_count = retry_count + 1
    msg.info("ytdl-retry: attempt " .. retry_count .. "/" .. max_retries ..
             " in " .. retry_delay .. "s for: " .. current_path)
    mp.osd_message("Retrying (" .. retry_count .. "/" .. max_retries .. ")...", retry_delay)

    mp.add_timeout(retry_delay, function()
        if current_path then
            mp.commandv("loadfile", current_path, "replace")
        end
    end)
end

mp.register_event("start-file", on_start_file)
mp.register_event("end-file", on_end_file)
