-- modified from https://github.com/rkscv/danmaku/blob/main/danmaku.lua
local msg = require('mp.msg')
local utils = require("mp.utils")
local unpack = unpack or table.unpack

local osd_width, osd_height, pause = 0, 0, true
local time_pos_observer_active = false
local overlay_low = mp.create_osd_overlay('ass-events')
local overlay_high = mp.create_osd_overlay('ass-events')
local ass_sub_id = nil
local ass_sub_path = nil
local saved_secondary_state = nil
local syncing_smooth_fps = false
local ass_loaded_path = nil
local ass_loaded_signature = nil
local ass_reload_pending = false
local SMOOTH_FPS_SUSPEND = "user-data/uosc_danmaku/suspend-smooth-fps"

local function is_ass_render_mode()
    return tostring(options.render_mode or "overlay") == "ass"
end

local function get_ass_sub_path()
    if ass_sub_path then return ass_sub_path end
    local name = string.format("uosc-danmaku-%s.ass", PID or utils.getpid())
    ass_sub_path = utils.join_path(DANMAKU_PATH or (os.getenv("TEMP") or "/tmp/"), name)
    return ass_sub_path
end

local function find_sub_track_id_by_path(path)
    local tracks = mp.get_property_native("track-list") or {}
    for _, track in ipairs(tracks) do
        if track.type == "sub" and (track["external-filename"] == path or track.title == "uosc_danmaku") then
            return track.id
        end
    end
end

local function remove_ass_subtitle(restore_secondary)
    local id = ass_sub_id or (ass_sub_path and find_sub_track_id_by_path(ass_sub_path))
    if id then
        mp.commandv("sub-remove", id)
        ass_sub_id = nil
    end
    ass_loaded_path = nil
    ass_loaded_signature = nil
    ass_reload_pending = false
    if restore_secondary ~= false and saved_secondary_state then
        mp.set_property_native("secondary-sub-ass-override", saved_secondary_state.ass_override)
        mp.set_property_native("secondary-sub-visibility", saved_secondary_state.visibility)
        mp.set_property_native("secondary-sid", saved_secondary_state.sid)
        saved_secondary_state = nil
    end
end

local function has_non_smooth_video_filter()
    local filters = mp.get_property_native("vf") or {}
    for _, filter in ipairs(filters) do
        if filter.label ~= "danmaku_smooth" then
            return true
        end
    end
    return false
end

local function has_smooth_fps_filter()
    local filters = mp.get_property_native("vf") or {}
    for _, filter in ipairs(filters) do
        if filter.label == "danmaku_smooth" then
            return true
        end
    end
    return false
end

local function sync_smooth_fps_filter()
    if syncing_smooth_fps then return end
    local should_enable = is_ass_render_mode() and options.vf_fps and get_danmaku_visibility()
    if should_enable then
        local display_fps = mp.get_property_number('display-fps')
        local suspended = mp.get_property_bool(SMOOTH_FPS_SUSPEND, false)
        should_enable = not suspended and not (display_fps and display_fps < 58) and not has_non_smooth_video_filter()
    end

    if should_enable then
        if not has_smooth_fps_filter() then
            syncing_smooth_fps = true
            mp.commandv("vf", "append", string.format("@danmaku_smooth:fps=fps=%s", options.fps))
            syncing_smooth_fps = false
        end
    elseif has_smooth_fps_filter() then
        syncing_smooth_fps = true
        mp.commandv("vf", "remove", "@danmaku_smooth")
        syncing_smooth_fps = false
    end
end

local function ass_time(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    local centiseconds = math.floor(seconds * 100 + 0.5)
    local cs = centiseconds % 100
    local total_seconds = math.floor(centiseconds / 100)
    local s = total_seconds % 60
    local total_minutes = math.floor(total_seconds / 60)
    local m = total_minutes % 60
    local h = math.floor(total_minutes / 60)
    return string.format("%d:%02d:%02d.%02d", h, m, s, cs)
end

local function strip_position_tags(text)
    return text:gsub("\\pos%(.-%)", ""):gsub("\\move%(.-%)", "")
end

local function ass_event_line(event)
    local layer = tonumber(event.layer) or 0
    local style = event.style or "R2L"
    local text = event.text or ""
    if event.move then
        local x1, y1, x2, y2 = unpack(event.move)
        text = strip_position_tags(text)
        local t1 = 0
        local t2 = math.max(t1 + 1, math.floor(((event.end_time or 0) - (event.start_time or 0)) * 1000))
        text = string.format("{\\move(%d,%d,%d,%d,%d,%d)\\an8}%s", math.floor(x1 + 0.5), math.floor(y1 + 0.5), math.floor(x2 + 0.5), math.floor(y2 + 0.5), t1, t2, text)
    elseif event.pos then
        local x, y = unpack(event.pos)
        text = strip_position_tags(text)
        local an = style == "BTM" and 2 or ((style == "SP" or style == "MSG") and 7 or 8)
        text = string.format("{\\pos(%d,%d)\\an%d}%s", math.floor(x + 0.5), math.floor(y + 0.5), an, text)
    end
    return string.format("Dialogue: %d,%s,%s,%s,,0,0,0,,%s", layer, ass_time(event.start_time), ass_time(event.end_time), style, text)
end

local function ass_render_signature()
    local count = COMMENTS and #COMMENTS or 0
    local first = count > 0 and COMMENTS[1] or {}
    local last = count > 0 and COMMENTS[count] or {}
    return table.concat({
        tostring(count),
        tostring(first.start_time or ""),
        tostring(first.end_time or ""),
        tostring(last.start_time or ""),
        tostring(last.end_time or ""),
        tostring(DELAY or 0),
        tostring(options.fontname),
        tostring(options.fontsize),
        tostring(options.opacity),
        tostring(options.outline),
        tostring(options.shadow),
        tostring(options.bold),
        tostring(options.displayarea),
        tostring(options.scrolltime),
        tostring(options.fixtime),
    }, "|")
end

local function write_ass_file(path)
    if COMMENTS == nil then return false end
    local file = io.open(path, "w")
    if not file then
        msg.error("无法写入 ASS 弹幕文件: " .. path)
        return false
    end

    local fontsize = tonumber(options.fontsize) or 50
    local opacity = tonumber(options.opacity) or 0.7
    local alpha = string.format("%02X", math.floor((1 - opacity) * 255 + 0.5))
    local outline = tonumber(options.outline) or 1
    local shadow = tonumber(options.shadow) or 0
    local bold = options.bold and -1 or 0

    file:write("[Script Info]\n")
    file:write("ScriptType: v4.00+\n")
    file:write("PlayResX: 1920\n")
    file:write("PlayResY: 1080\n")
    file:write("WrapStyle: 2\n")
    file:write("ScaledBorderAndShadow: yes\n\n")
    file:write("[V4+ Styles]\n")
    file:write("Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n")
    file:write(string.format("Style: R2L,%s,%d,&H%sFFFFFF,&H%sFFFFFF,&H00000000,&H00000000,%d,0,0,0,100,100,0,0,1,%s,%s,8,0,0,0,1\n", options.fontname, fontsize, alpha, alpha, bold, outline, shadow))
    file:write(string.format("Style: TOP,%s,%d,&H%sFFFFFF,&H%sFFFFFF,&H00000000,&H00000000,%d,0,0,0,100,100,0,0,1,%s,%s,8,0,0,0,1\n", options.fontname, fontsize, alpha, alpha, bold, outline, shadow))
    file:write(string.format("Style: BTM,%s,%d,&H%sFFFFFF,&H%sFFFFFF,&H00000000,&H00000000,%d,0,0,0,100,100,0,0,1,%s,%s,2,0,0,0,1\n", options.fontname, fontsize, alpha, alpha, bold, outline, shadow))
    file:write("\n[Events]\n")
    file:write("Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n")

    for _, event in ipairs(COMMENTS or {}) do
        file:write(ass_event_line(event))
        file:write("\n")
    end
    file:close()
    return true
end

local function load_ass_subtitle(path, signature)
    ass_reload_pending = true
    local old_id = ass_sub_id or (ass_sub_path and find_sub_track_id_by_path(ass_sub_path))
    if old_id then
        mp.commandv("sub-remove", old_id)
        ass_sub_id = nil
    end
    if not saved_secondary_state then
        saved_secondary_state = {
            sid = mp.get_property_native("secondary-sid"),
            visibility = mp.get_property_native("secondary-sub-visibility"),
            ass_override = mp.get_property_native("secondary-sub-ass-override"),
        }
    end
    mp.commandv("sub-add", path, "auto", "uosc_danmaku")
    ass_sub_id = find_sub_track_id_by_path(path)
    if ass_sub_id then
        mp.set_property_native("secondary-sub-ass-override", "yes")
        mp.set_property_native("secondary-sid", ass_sub_id)
        mp.set_property_native("secondary-sub-visibility", true)
    end
    ass_loaded_path = path
    ass_loaded_signature = signature
    ass_reload_pending = false
end

local function render_ass_danmaku()
    if COMMENTS == nil then return end
    local path = get_ass_sub_path()
    local signature = ass_render_signature()
    ass_sub_id = ass_sub_id or find_sub_track_id_by_path(path)
    if ass_loaded_path == path and ass_loaded_signature == signature and ass_sub_id and not ass_reload_pending then
        sync_smooth_fps_filter()
        return
    end
    if write_ass_file(path) then
        load_ass_subtitle(path, signature)
        sync_smooth_fps_filter()
    end
end

local function realtime_position_text(event, pos, displayarea)
    if not event.move then
        local _, current_y = unpack(event.pos)
        if not current_y or tonumber(current_y) > displayarea then return end
        if event.style ~= "SP" and event.style ~= "MSG" then
            return string.format("{\\an8}%s", event.text)
        else
            return string.format("{\\an7}%s", event.text)
        end
    end

    local x1, y1, x2, y2 = unpack(event.move)
    -- 计算移动的时间范围
    local duration = event.end_time - event.start_time  --mean: options.scrolltime
    local progress = (pos - event.start_time) / duration  -- 移动进度 [0, 1]

    -- 计算当前坐标
    local current_x = tonumber(x1 + (x2 - x1) * progress)
    local current_y = tonumber(y1 + (y2 - y1) * progress)

    -- 移除 \move 标签并应用当前坐标
    local clean_text = event.text:gsub("\\move%(.-%)", "")
    if current_y > displayarea then return end
    if event.style ~= "SP" and event.style ~= "MSG" then
        return string.format("{\\pos(%.1f,%.1f)\\an8}%s", current_x, current_y, clean_text)
    else
        return string.format("{\\pos(%.1f,%.1f)\\an7}%s", current_x, current_y, clean_text)
    end
end

function render(pos_arg)
    if COMMENTS == nil then return end

    if is_ass_render_mode() then
        render_ass_danmaku()
        return
    end

    local pos, err
    if pos_arg == nil then
        pos, err = mp.get_property_number('time-pos')
        if err ~= nil then
            return msg.error(err)
        end
    else
        pos = pos_arg
    end

    if not pos then
        overlay_low:remove()
        overlay_high:remove()
        return
    end

    local fontname = options.fontname
    local fontsize = options.fontsize
    local opacity = tonumber(options.opacity)
    local alpha = string.format("%02X", (1 - (opacity or 0)) * 255)

    local width, height = 1920, 1080
    local ratio = osd_width / osd_height
    if width / height < ratio then
        height = width / ratio
        fontsize = options.fontsize - ratio * 2
    end

    local ass_events_low = {}
    local ass_events_high = {}
    local max_display = math.max(options.scrolltime, options.fixtime)
    local window_start = pos - max_display

    -- 跳过已结束的弹幕
    local lo = binary_search(COMMENTS, window_start, function(item) return item.start_time end)

    local re_entity = "&#%d+;"
    local re_fs = "\\fs(%d+)"
    local ass_prefix = string.format("{\\rDefault\\fn%s\\fs%d\\c&HFFFFFF&\\alpha&H%s\\bord%s\\shad%s\\b%s\\q2}",
        fontname, fontsize, alpha, options.outline, options.shadow, options.bold and "1" or "0")

    for i = lo, #COMMENTS do
        local event = COMMENTS[i]
        if not event then break end

        if event.start_time > pos then break end  -- 后续弹幕提前退出
        if event.end_time >= pos then
            local text = realtime_position_text(event, pos, height * options.displayarea)
            if text then
                text = text:gsub(re_entity, "")
            end

            if text and text:match(re_fs) then
                text = text:gsub(re_fs, function(size)
                    local n = tonumber(size) or 0
                    return string.format("\\fs%d", math.floor(n * 1.5))
                end)
            end

            -- 构建 ASS 字符串
            local ass_text = text and (ass_prefix .. text)
            if ass_text then
                if event.layer == nil or tonumber(event.layer) == 0 then
                    table.insert(ass_events_low, ass_text)
                else
                    table.insert(ass_events_high, ass_text)
                end
            end
        end
    end

    -- 写入低层（滚动）和高层（顶/底）overlay，并设置 z 值以控制堆叠
    overlay_low.res_x = width
    overlay_low.res_y = height
    overlay_low.z = 0
    overlay_low.data = table.concat(ass_events_low, '\n')
    overlay_low:update()

    overlay_high.res_x = width
    overlay_high.res_y = height
    overlay_high.z = 1
    overlay_high.data = table.concat(ass_events_high, '\n')
    overlay_high:update()
end

local function time_pos_callback(_, time_pos)
    if time_pos then
        render(time_pos)
    else
        overlay_low:remove()
        overlay_high:remove()
    end
end

local function start_time_observer()
    if not time_pos_observer_active then
        mp.observe_property('time-pos', 'number', time_pos_callback)
        time_pos_observer_active = true
    end
end

local function stop_time_observer()
    if time_pos_observer_active then
        mp.unobserve_property(time_pos_callback)
        time_pos_observer_active = false
    end
end

function render_danmaku(from_menu, no_osd)
    if ENABLED and (from_menu or get_danmaku_visibility()) then
        if not no_osd then
            show_loaded(true)
        end
        toggle_danmaku_switch("on")
        show_danmaku_func()
    else
        show_message("")
        hide_danmaku_func()
    end
end

local function filter_state(label, name)
    local filters = mp.get_property_native("vf")
    for _, filter in pairs(filters) do
        if filter.label == label or filter.name == name
        or filter.params[name] ~= nil then
            return true
        end
    end
    return false
end

function show_danmaku_func()
    mp.set_property_bool(HAS_DANMAKU, true)
    set_danmaku_visibility(true)
    if is_ass_render_mode() then
        overlay_low:remove()
        overlay_high:remove()
        render_ass_danmaku()
        return
    end
    render()
    if not pause then
        start_time_observer()
    end
    if options.vf_fps then
        local display_fps = mp.get_property_number('display-fps')
        local video_fps = mp.get_property_number('estimated-vf-fps')
        if (display_fps and display_fps < 58) or (video_fps and video_fps > 58) then
            return
        end
        if not filter_state("danmaku", "fps") then
            mp.commandv("vf", "append", string.format("@danmaku:fps=fps=%s", options.fps))
        end
    end
end

function hide_danmaku_func()
    stop_time_observer()
    mp.set_property_bool(HAS_DANMAKU, false)
    set_danmaku_visibility(false)
    overlay_low:remove()
    overlay_high:remove()
    remove_ass_subtitle()
    sync_smooth_fps_filter()
    if filter_state("danmaku") then
        mp.commandv("vf", "remove", "@danmaku")
    end
end

local message_overlay = mp.create_osd_overlay('ass-events')
local message_timer = mp.add_timeout(3, function()
    message_overlay:remove()
end, true)

function show_message(text, time)
    message_timer.timeout = time or 3
    message_timer:kill()
    message_overlay:remove()
    local message = string.format("{\\an%d\\pos(%d,%d)}%s", options.message_anlignment,
       options.message_x, options.message_y, text)
    local width, height = 1920, 1080
    local ratio = osd_width / osd_height
    if width / height < ratio then
        height = width / ratio
    end
    message_overlay.res_x = width
    message_overlay.res_y = height
    message_overlay.data = message
    message_overlay:update()
    message_timer:resume()
end

mp.observe_property('osd-width', 'number', function(_, value) osd_width = value or osd_width end)
mp.observe_property('osd-height', 'number', function(_, value) osd_height = value or osd_height end)
mp.observe_property('pause', 'bool', function(_, value)
    if value ~= nil then
        pause = value
    end
    if ENABLED then
        if pause then
            stop_time_observer()
        elseif COMMENTS ~= nil then
            start_time_observer()
        end
    end
end)

mp.observe_property('vf', 'native', function()
    sync_smooth_fps_filter()
end)

mp.register_event('playback-restart', function(event)
    if event.error then
        return msg.error(event.error)
    end
    if ENABLED and COMMENTS ~= nil and not ass_reload_pending then
        render()
    end
end)

mp.add_hook("on_unload", 50, function()
    COMMENTS, DELAY = nil, 0
    stop_time_observer()
    overlay_low:remove()
    overlay_high:remove()
    remove_ass_subtitle()
    sync_smooth_fps_filter()
    mp.set_property_native(DELAY_PROPERTY, 0)
    if filter_state("danmaku") then
        mp.commandv("vf", "remove", "@danmaku")
    end

    local files_to_remove = {
        file1 = utils.join_path(DANMAKU_PATH, "temp-" .. PID .. ".mp4"),
    }

    if options.save_danmaku then
        save_danmaku(true)
    end

    for _, file in pairs(files_to_remove) do
        if file_exists(file) then
            os.remove(file)
        end
    end

    DANMAKU = {sources = {}, count = 1}
    mp.set_property_native(DANMAKU_COUNT, 0)
end)
