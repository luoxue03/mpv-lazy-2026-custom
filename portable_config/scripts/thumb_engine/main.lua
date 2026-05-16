--[[
文档_ https://github.com/hooke007/mpv_PlayKit/discussions/668

Fork of https://github.com/po5/thumbfast/blob/master/thumbfast.lua

缩略图引擎

可用的快捷键示例（在 input.conf 中写入）：

 <KEY>   script-binding thumb_engine/thumb_rerun    # 重启缩略图的获取（可用来手动修复缩略图卡死）
 <KEY>   script-binding thumb_engine/thumb_toggle   # 开/关缩略图预览
 <KEY>   script-message thumbnail_hwdec toggle      # 开/关缩略图的硬解（可将其中的 {toggle} 参数换成指定的解码API）

]]

local mp = require "mp"
mp.options = require "mp.options"
mp.utils = require "mp.utils"

local helper  = require "helper"
local winapi  = require "winapi"
local process = require "process"
local batch   = require "batch"

local options = {

	load = true,


	-- 单帧模式
	backend = "mpv",
	binpath = "default",
	socket = "",
	tnpath = "",

	max_height = 320,
	max_width = 320,
	rescale = 0,
	overlay_id = 10,

	spawn_first = false,
	quit_after_inactivity = 0,
	network = false,
	audio = false,
	direct_io = true,

	hwdec = "yes",
	sw_threads = 2,
	min_duration = 10,
	precise = 0,
	quality = 1,
	frequency = 0.125,
	cache_iframe = "auto",
	cache_max = 128,
	be_workers = 3,

	-- 批量模式
	bat_backend = "ffmpeg",
	bat_binpath = "default",
	bat_path = "",
	bat_overlay_ids = "11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35",
	bat_width = 320,
	bat_height = 320,
	bat_hwdec = "yes",
	bat_threads = 1,
	bat_be_workers = 3,
	bat_min_duration = 20,

}
mp.options.read_options(options)

if options.load == false then
	mp.msg.info("脚本已被初始化禁用")
	return
end
-- 原因：--load-osd-console 重命名为 --load-console
local min_major = 0
local min_minor = 40
local min_patch = 0
local mpv_ver_curr = mp.get_property_native("mpv-version", "unknown")
if helper.incompat_check(mpv_ver_curr, min_major, min_minor, min_patch) then
	mp.msg.warn("当前mpv版本 (" .. (mpv_ver_curr or "未知") .. ") 低于 " .. min_major .. "." .. min_minor .. "." .. min_patch .. "，已终止缩略图功能。")
	return
end

local os_name = mp.get_property("platform")

if options.tnpath == "" then
	if os_name == "windows" then
		options.tnpath = os.getenv("TEMP").."\\thumb_engine.out"
	else
		options.tnpath = "/tmp/thumb_engine.out"
	end
end

local unique = mp.utils.getpid()

options.tnpath = options.tnpath .. unique

if options.backend == "mpv" then
	if options.socket == "" then
		if os_name == "windows" then
			options.socket = "thumb_engine"
		else
			options.socket = "/tmp/thumb_engine"
		end
	end
	options.socket = options.socket .. unique

	-- 初始化 winapi（可能禁用 direct_io）
	winapi.init(options, os_name)
end

-- 共享状态表
local state = {
	-- IPC / file handles
	file = nil,
	file_bytes = 0,

	-- process state
	spawned = false,
	disabled = false,
	spawn_waiting = false,
	spawn_working = false,
	script_written = false,

	-- dirty flag for property change batching
	dirty = false,

	-- cursor position
	x = nil, y = nil,
	last_x = nil, last_y = nil,

	-- seek
	last_seek_time = nil,

	-- dimensions
	effective_w = options.max_width,
	effective_h = options.max_height,
	real_w = nil, real_h = nil,
	last_real_w = nil, last_real_h = nil,

	-- video state
	script_name = nil,
	show_thumbnail = false,
	has_vid = 0,
	last_has_vid = 0,

	-- toggle
	auto_run = true,

	-- info timer
	info_timer = nil,

	-- properties table (observed mpv properties cache)
	properties = {},

	-- timers (will be set below)
	activity_timer = nil,

	-- remove_thumbnail_files callback (set below, used by process.spawn)
	remove_thumbnail_files = nil,
}

-- OSC Preview API 状态
local preview_draw = nil
local preview_ass = mp.create_osd_overlay("ass-events")

-- 初始化 process 模块
process.init(state, options, os_name, winapi)
process.init_seek()

-- 初始化 batch 模块
batch.init(options, os_name)


-- =============================================================================
-- 显示 广播
-- =============================================================================

-- 批量模式配置独立广播
local function bat_info()
	local json = mp.utils.format_json({
		bat_width = options.bat_width,
		bat_height = options.bat_height,
		bat_overlay_ids = options.bat_overlay_ids,
		bat_path = options.bat_path,
	})
	mp.command_native_async({"script-message", "thumb_engine-bat-info", json}, function() end)
end

state.remove_thumbnail_files = function() helper.remove_thumbnail_files(state, options) end

local function info(w, h)
	local short_video = mp.get_property_number("duration", 0) <= options.min_duration
	local image = state.properties["current-tracks/video"] and state.properties["current-tracks/video"]["image"]
	local albumart = image and state.properties["current-tracks/video"]["albumart"]

	state.disabled = (w or 0) == 0 or (h or 0) == 0 or
		state.has_vid == 0 or
		(state.properties["demuxer-via-network"] and not options.network) or
		(albumart and not options.audio) or
		(image and not albumart) or
		(short_video and options.min_duration > 0)

	if not state.auto_run then
		state.disabled = true
	end

	if state.info_timer then
		state.info_timer:kill()
		state.info_timer = nil
	elseif state.has_vid == 0 or not state.disabled then
		state.info_timer = mp.add_timeout(0.05, function() info(w, h) end)
	end

	local json, err = mp.utils.format_json({
		width=w, height=h, disabled=state.disabled, available=true,
		socket=options.socket, tnpath=options.tnpath, overlay_id=options.overlay_id,
	})
	mp.command_native_async({"script-message", "thumb_engine-info", json}, function() end)

	-- OSC Preview API: 通知 osc 缩略图引擎是否可用
	mp.set_property_native("user-data/mpv/thumbnailer/enabled", not state.disabled)
end

local function draw(w, h, script)
	if not w or not state.show_thumbnail then return end

	if state.x ~= nil then
		local cmd_x, cmd_y = state.x, state.y
		local cmd_w, cmd_h = nil, nil
		local preview = preview_draw and preview_draw.x and preview_draw.y and preview_draw.w and preview_draw.h
		if preview then
			cmd_x, cmd_y = preview_draw.x, preview_draw.y
			cmd_w, cmd_h = preview_draw.w, preview_draw.h
		end
		-- 旧版使用的异步调用可能会导致个别缩略图异常
		-- mp.command_native_async({name = "overlay-add", id=options.overlay_id, x=cmd_x, y=cmd_y, file=options.tnpath..".bgra", offset=0, fmt="bgra", w=w, h=h, stride=(4*w)}, function() end)
		mp.command_native({name = "overlay-add", id=options.overlay_id, x=cmd_x, y=cmd_y, file=options.tnpath..".bgra", offset=0, fmt="bgra", w=w, h=h, stride=(4*w), dw=cmd_w, dh=cmd_h})
		if preview then
			local ass = preview_draw.ass or ""
			local osd_w, osd_h = mp.get_osd_size()
			if osd_w > 0 and osd_h > 0 then
				preview_ass.res_x = osd_w
				preview_ass.res_y = osd_h
				preview_ass.data = ass
				preview_ass:update()
			end
		end
	elseif script then
		local json, err = mp.utils.format_json({width=w, height=h, x=state.x, y=state.y, socket=options.socket, tnpath=options.tnpath, overlay_id=options.overlay_id})
		mp.commandv("script-message-to", script, "thumb_engine-render", json)
	end
end

-- =============================================================================
-- 缩略图文件检测
-- =============================================================================

local file_timer
local file_check_period = 1/60

file_timer = mp.add_periodic_timer(file_check_period, function()
	local w, h = helper.check_new_thumb(options, state, os_name)
	if w then
		state.real_w, state.real_h = w, h
		if state.real_w ~= state.last_real_w or state.real_h ~= state.last_real_h then
			state.last_real_w, state.last_real_h = state.real_w, state.real_h
			info(state.real_w, state.real_h)
		end
		if not state.show_thumbnail then
			file_timer:kill()
		end
		draw(state.real_w, state.real_h, state.script_name)
	end
end)
file_timer:kill()

-- =============================================================================
-- 生命周期
-- =============================================================================

local activity_timer

local function clear(force_overlay_remove)
	file_timer:kill()
	process.kill_seek_timer()
	if options.quit_after_inactivity > 0 then
		if state.show_thumbnail or activity_timer:is_enabled() then
			activity_timer:kill()
		end
		activity_timer:resume()
	end
	state.show_thumbnail = false
	state.last_x = nil
	state.last_y = nil
	preview_ass:remove()
	if state.script_name and not force_overlay_remove then return end
	mp.command_native_async({name = "overlay-remove", id=options.overlay_id}, function() end)
end

local function quit()
	activity_timer:kill()
	if state.show_thumbnail then
		activity_timer:resume()
		return
	end
	process.run("quit")
	state.spawned = false
	state.real_w, state.real_h = nil, nil
	clear()
end

activity_timer = mp.add_timeout(options.quit_after_inactivity, quit)
activity_timer:kill()
state.activity_timer = activity_timer

-- =============================================================================
-- 消息处理
-- =============================================================================

local function thumb(time, r_x, r_y, script)
	if state.disabled then return end

	time = tonumber(time)
	if time == nil then return end

	if r_x == "" or r_y == "" then
		state.x, state.y = nil, nil
	else
		state.x, state.y = math.floor(r_x + 0.5), math.floor(r_y + 0.5)
	end

	local was_showing = state.show_thumbnail

	state.script_name = script
	if state.last_x ~= state.x or state.last_y ~= state.y or not state.show_thumbnail then
		state.show_thumbnail = true
		state.last_x, state.last_y = state.x, state.y
		-- 从清除状态恢复时不绘制过期的旧缩略图，等待新帧生成
		if was_showing then
			draw(state.real_w, state.real_h, script)
		end
	end

	if options.quit_after_inactivity > 0 then
		if state.show_thumbnail or activity_timer:is_enabled() then
			activity_timer:kill()
		end
		activity_timer:resume()
	end

	if time == state.last_seek_time then
		if not was_showing then draw(state.real_w, state.real_h, script) end
		return
	end
	-- 时间差极小时跳过重新seek，避免关键帧seek导致缩略图跳变
	if state.last_seek_time and math.abs(time - state.last_seek_time) < 0.05 then
		if not was_showing then draw(state.real_w, state.real_h, script) end
		return
	end
	state.last_seek_time = time
	if not state.spawned then process.spawn(time) end
	process.request_seek()
	if not file_timer:is_enabled() then file_timer:resume() end
end

-- =============================================================================
-- OSC Preview API
-- =============================================================================

local function preview_update_draw(name, value)
	preview_draw = value

	if preview_draw == nil then
		clear(true)
		return
	end

	local hover_sec = mp.get_property_number("user-data/osc/hover-sec")
	thumb(hover_sec, value.x, value.y, nil)
end

-- =============================================================================
-- 属性观察
-- =============================================================================

local function watch_changes()
	if not state.dirty or not state.properties["video-params"] then return end
	state.dirty = false

	local old_w = state.effective_w
	local old_h = state.effective_h

	helper.calc_dimensions(state, options)

	local resized = old_w ~= state.effective_w or old_h ~= state.effective_h

	if resized then
		info(state.effective_w, state.effective_h)
	elseif state.last_has_vid ~= state.has_vid and state.has_vid ~= 0 then
		info(state.effective_w, state.effective_h)
	end

	if state.spawned then
		if resized then
			-- mpv doesn't allow us to change output size
			local seek_time = state.last_seek_time
			process.run("quit")
			clear()
			state.spawned = false
			process.spawn(seek_time or mp.get_property_number("time-pos", 0))
			file_timer:resume()
		end
	end

	state.last_has_vid = state.has_vid

	if not state.spawned and not state.disabled and options.spawn_first and resized then
		process.spawn(mp.get_property_number("time-pos", 0))
		file_timer:resume()
	end
end

local function update_property(name, value)
	state.properties[name] = value
end

local function update_property_dirty(name, value)
	state.properties[name] = value
	state.dirty = true
end

local function update_tracklist(name, value)
	-- current-tracks shim
	for _, track in ipairs(value) do
		if track.type == "video" and track.selected then
			state.properties["current-tracks/video"] = track
			return
		end
	end
end

local function sync_changes(prop, val)
	update_property(prop, val)
	if val == nil then return end

	if type(val) == "boolean" then
		if prop == "vid" then
			state.has_vid = 0
			state.last_has_vid = 0
			info(state.effective_w, state.effective_h)
			clear()
			return
		end
		val = val and "yes" or "no"
	end

	if prop == "vid" then
		state.has_vid = 1
	end

	if not state.spawned then return end

	process.run("set "..prop.." "..val)
	state.dirty = true
end

local function file_load(skip_batch_cancel)
	preview_draw = nil
	clear(true)
	if not skip_batch_cancel then
		batch.batch_cancel()
	end
	state.spawned = false
	state.real_w, state.real_h = nil, nil
	state.last_real_w, state.last_real_h = nil, nil
	state.last_seek_time = nil
	if state.info_timer then
		state.info_timer:kill()
		state.info_timer = nil
	end

	helper.calc_dimensions(state, options)
	info(state.effective_w, state.effective_h)

	-- always 模式：延迟启动预填充，等待初始属性变化（分辨率等）稳定
	if options.cache_iframe == "always" and options.backend == "ffmpeg" then
		mp.add_timeout(1, function()
			if state.disabled then return end
			if not state.spawned then
				process.spawn(mp.get_property_number("time-pos", 0))
			end
			process.prefill_cache()
		end)
	end
end

local function shutdown()
	batch.batch_cancel(true)
	process.run("quit")
	helper.remove_thumbnail_files(state, options)
	if options.backend == "mpv" and os_name ~= "windows" then
		os.remove(options.socket)
		os.remove(options.socket..".run")
	end
end

-- =============================================================================
-- 注册事件
-- =============================================================================

mp.observe_property("current-tracks/video", "native", function(name, value)
	update_property(name, value)
end)

mp.observe_property("track-list", "native", update_tracklist)
mp.observe_property("display-hidpi-scale", "native", update_property_dirty)
mp.observe_property("video-params", "native", update_property_dirty)
mp.observe_property("video-dec-params", "native", update_property_dirty)
mp.observe_property("demuxer-via-network", "native", update_property)
mp.observe_property("stream-open-filename", "native", update_property)
mp.observe_property("path", "native", update_property)
mp.observe_property("vid", "native", sync_changes)
mp.observe_property("edition", "native", sync_changes)

-- OSC Preview API 的 draw-preview
mp.observe_property("user-data/osc/draw-preview", "native", preview_update_draw)

-- thumbfast api兼容接口
mp.register_script_message("thumb", thumb)
mp.register_script_message("clear", clear)
-- 防脚本消息歧义的接口
mp.register_script_message("thumbnail_gen", thumb)
mp.register_script_message("thumbnail_clr", clear)

mp.register_event("file-loaded", function() file_load() end)
mp.register_event("shutdown", shutdown)

-- 广播批量配置
mp.register_event("file-loaded", function() bat_info() end)
-- 响应外部主动查询
mp.register_script_message("thumb_engine-bat-info?", function() bat_info() end)

mp.add_key_binding(nil, "thumb_rerun", function()
	clear()
	shutdown()
	state.auto_run = true
	file_load(true)
	mp.osd_message("缩略图功能已重启", 2)
	mp.msg.info("缩略图功能已重启")
end)
mp.add_key_binding(nil, "thumb_toggle", function()
	if state.auto_run then
		state.auto_run = false
		clear()
		shutdown()
		file_load(true)
		mp.osd_message("缩略图功能已临时禁用", 2)
		mp.msg.info("缩略图功能已临时禁用")
	else
		state.auto_run = true
		file_load(true)
		mp.osd_message("缩略图功能已临时启用", 2)
		mp.msg.info("缩略图功能已临时启用")
	end
end)
mp.register_script_message("thumbnail_hwdec", function(hwdec_api)
	local hwdec_api_cur = options.hwdec
	if hwdec_api_cur == hwdec_api then return end
	if hwdec_api == "toggle" then
		if hwdec_api_cur == "no" then
			hwdec_api = "yes"
		else
			hwdec_api = "no"
		end
	end
	options.hwdec = hwdec_api
	mp.osd_message("缩略图已变更首选解码API：" .. hwdec_api, 2)
	mp.msg.info("缩略图已变更首选解码API：" .. hwdec_api)
	clear()
	shutdown()
	file_load(true)
end)

-- 批量帧提取消息
mp.register_script_message("batch_gen", function(json_str)
	local params = mp.utils.parse_json(json_str)
	if not params then return end
	if options.bat_min_duration > 0 then
		local duration = mp.get_property_number("duration", 0)
		if duration <= options.bat_min_duration then
			mp.msg.verbose("batch_gen: skipped, duration " .. duration .. "s <= bat_min_duration " .. options.bat_min_duration .. "s")
			return
		end
	end
	batch.batch_extract(params)
end)
mp.register_script_message("batch_pause", function()
	batch.batch_pause()
end)
mp.register_script_message("batch_clr", function(rmdir)
	batch.batch_cancel(rmdir == "rmdir")
end)

mp.register_idle(watch_changes)
