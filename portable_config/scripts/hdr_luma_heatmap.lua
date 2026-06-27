-- Generate a false-color luma heatmap for the current frame.
-- This uses mpv's normal screenshot path, then runs the bundled Python helper.

local utils = require "mp.utils"

local function join_path(...)
    return utils.join_path(...)
end

local function windows_path(path)
    return path:gsub("/", "\\")
end

local function normalize_dir(path)
    return path:gsub("\\", "/"):gsub("/+$", "")
end

local function parent_dir(path)
    return normalize_dir(path):match("^(.*)/[^/]+$") or "."
end

local function cleanup_old_outputs(out_dir)
    local now = os.time()
    local files = utils.readdir(out_dir, "files") or {}
    for _, name in ipairs(files) do
        if name:match("^hdr%-luma%-") then
            local path = join_path(out_dir, name)
            local info = utils.file_info(path)
            if info and info.mtime and now - info.mtime > 7 * 24 * 60 * 60 then
                os.remove(path)
            end
        end
    end
end

local function run_heatmap()
    local helper = mp.find_config_file("scripts/hdr_luma_heatmap.py")
    if not helper then
        mp.osd_message("HDR亮度热力图脚本缺失", 4)
        mp.msg.error("scripts/hdr_luma_heatmap.py was not found in mpv config paths")
        return
    end
    local scripts_dir = parent_dir(helper)
    local config_dir = parent_dir(scripts_dir)
    local mpv_dir = parent_dir(config_dir)
    local out_dir = join_path(config_dir, "_cache")
    cleanup_old_outputs(out_dir)

    local stamp = os.date("%Y%m%d-%H%M%S")
    local shot = join_path(out_dir, "hdr-luma-" .. stamp .. "-source.ppm")
    local heat = join_path(out_dir, "hdr-luma-" .. stamp .. "-heatmap.png")
    local peak = join_path(out_dir, "hdr-luma-" .. stamp .. "-peakmask.png")
    local report = join_path(out_dir, "hdr-luma-" .. stamp .. "-report.txt")
    local python = join_path(mpv_dir, "python.exe")

    local image = mp.command_native({ "screenshot-raw", "video", "rgba" })
    if not image or not image.data then
        mp.osd_message("HDR亮度热力图截图失败", 4)
        mp.msg.error("screenshot-raw returned no image data")
        return
    end

    local file = io.open(shot, "wb")
    if not file then
        mp.osd_message("HDR亮度热力图写入失败", 4)
        mp.msg.error("failed to open " .. shot)
        return
    end
    local width = image.w or image.width
    local height = image.h or image.height
    local stride = image.stride or (width * 4)
    local abs_stride = math.abs(stride)
    local bytes_per_pixel = 4

    file:write(string.format("P6\n%d %d\n255\n", width, height))
    for y = 0, height - 1 do
        local row = stride >= 0 and y or (height - 1 - y)
        local start = row * abs_stride + 1
        for x = 0, width - 1 do
            local p = start + x * bytes_per_pixel
            file:write(image.data:sub(p, p + 2))
        end
    end
    file:close()

    local out_params = mp.get_property_native("video-out-params") or {}
    local args = { python, helper, shot, heat, "--report", report }
    if out_params["max-pq-y"] then
        table.insert(args, "--mpv-max-pq-y")
        table.insert(args, tostring(out_params["max-pq-y"]))
    end
    if out_params["avg-pq-y"] then
        table.insert(args, "--mpv-avg-pq-y")
        table.insert(args, tostring(out_params["avg-pq-y"]))
    end

    local result = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = args,
    })

    if result.status ~= 0 then
        local err = result.stderr or result.stdout or "unknown error"
        mp.osd_message("HDR亮度热力图生成失败", 4)
        mp.msg.error(err)
        return
    end

    mp.osd_message("已生成HDR亮度热力图和峰值区域图", 2)
    mp.msg.info(result.stdout or "")
    utils.subprocess({ args = { "cmd.exe", "/c", "start", "", heat }, detach = true })
    utils.subprocess({ args = { "cmd.exe", "/c", "start", "", peak }, detach = true })
    utils.subprocess({ args = { "cmd.exe", "/c", "start", "", report }, detach = true })
end

mp.register_script_message("hdr-luma-heatmap", run_heatmap)
