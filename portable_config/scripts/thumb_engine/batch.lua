local mp = require "mp"
mp.utils = require "mp.utils"

local M = {}

local options
local os_name

-- Batch state
local batch_ids = {}            -- { [async_id] = true }
local batch_queue = {}          -- { {index=, time=}, ... }
local batch_workers = 0
local batch_active = false
local batch_params = nil
local batch_completed = {}      -- { [index] = true }
local batch_failed = 0
local batch_overlay_shown = {}  -- { [overlay_id] = true }

function M.init(_options, _os_name)
	options = _options
	os_name = _os_name
end

-- =============================================================================
-- =============================================================================

local function get_bat_dir()
	local base = options.bat_path
	if not base or base == "" then
		if os_name == "windows" then
			base = os.getenv("TEMP") or os.getenv("TMP") or "C:/Temp"
		else
			base = "/tmp"
		end
	end
	base = base:gsub("[/\\]+$", "")
	return mp.utils.join_path(base, "thumb_bat" .. mp.utils.getpid())
end

local function parse_overlay_ids()
	local ids = {}
	local str = options.bat_overlay_ids
	if not str or str == "" then return ids end
	for id_str in str:gmatch("[^,]+") do
		local id = tonumber(id_str:match("^%s*(%d+)%s*$"))
		if id and id >= 0 and id <= 63 then
			ids[#ids + 1] = id
		end
	end
	return ids
end

-- =============================================================================
-- =============================================================================

local function ensure_dir(dir)
	if os_name == "windows" then
		dir = dir:gsub("/", "\\")
	end

	local info = mp.utils.file_info(dir)
	if info then return true end

	if os_name == "windows" then
		mp.command_native({
			name = "subprocess",
			args = {"cmd", "/c", "mkdir", dir},
			playback_only = false,
			capture_stdout = true,
			capture_stderr = true,
		})
	else
		mp.command_native({
			name = "subprocess",
			args = {"mkdir", "-p", dir},
			playback_only = false,
		})
	end

	return mp.utils.file_info(dir) ~= nil
end

-- =============================================================================
-- ffmpeg commands
-- =============================================================================

-- 多帧单进程 ffmpeg 命令：N 个 -ss/-i 输入 + N 个 -map 输出
local function build_bat_vf(width, height)
	local dvp = mp.get_property_number("current-tracks/video/dolby-vision-profile", 0)
	local hdr = mp.get_property_number("video-params/sig-peak", 1)
	local scale = "scale=" .. width .. ":" .. height .. ":flags=fast_bilinear"

	if dvp == 5 then
		return scale .. ",libplacebo=colorspace=bt709:color_primaries=bt709:color_trc=bt709:gamut_mode=desaturate:tonemapping=spline"
	elseif hdr > 1 then
		return scale .. ",zscale=t=linear:npl=150,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=4.0,zscale=t=bt709:m=bt709:r=tv"
	else
		return scale
	end
end

local function build_ffmpeg_multi_args(tasks, use_keyframe)
	local ffmpeg_path = options.bat_binpath == "default" and "ffmpeg" or options.bat_binpath
	local input_path = mp.get_property("path")
	if not input_path or input_path == "" then return nil end

	local args = { ffmpeg_path, "-loglevel", "quiet" }

	local hwaccel_args = {}
	if options.bat_hwdec ~= "no" then
		hwaccel_args[#hwaccel_args + 1] = "-hwaccel"
		if options.bat_hwdec == "yes" or options.bat_hwdec == "auto" then
			if os_name == "windows" then
				hwaccel_args[#hwaccel_args + 1] = "d3d11va"
			elseif os_name == "darwin" then
				hwaccel_args[#hwaccel_args + 1] = "videotoolbox"
			else
				hwaccel_args[#hwaccel_args + 1] = "auto"
			end
		else
			hwaccel_args[#hwaccel_args + 1] = options.bat_hwdec
		end
	end

	-- 输入：每个时间点一组
	for _, task in ipairs(tasks) do
		local per_input = {
			"-analyzeduration", "0",
			"-probesize", "128000",
			"-skip_loop_filter", "all",
			"-skip_idct", "all",
			"-flags2", "fast",
		}
		for _, v in ipairs(per_input) do args[#args + 1] = v end
		for _, v in ipairs(hwaccel_args) do args[#args + 1] = v end
		if use_keyframe then
			args[#args + 1] = "-noaccurate_seek"
		end
		args[#args + 1] = "-ss"
		args[#args + 1] = tostring(task.time)
		args[#args + 1] = "-i"
		args[#args + 1] = input_path
	end

	-- 输出：每个时间点一组
	for i, task in ipairs(tasks) do
		local output_path = mp.utils.join_path(batch_params._output_dir, "bat_" .. task.index .. ".bgra")
		local per_output = {
			"-map", (i - 1) .. ":v:0",
			"-threads", tostring(options.bat_threads),
			"-vframes", "1",
			"-an", "-sn", "-dn",
			"-vf", batch_params._vf,
			"-pix_fmt", "bgra",
			"-f", "rawvideo",
			"-y", output_path,
		}
		for _, v in ipairs(per_output) do args[#args + 1] = v end
	end

	return args
end

local function build_command(args)
	local command = {
		name = "subprocess",
		args = args,
		playback_only = true,
	}
	if os_name == "darwin" then
		command.env = "PATH=" .. os.getenv("PATH")
	end
	return command
end

-- =============================================================================
-- overlay
-- =============================================================================

local function bat_draw(index)
	if not batch_params then return end
	local overlay_id = batch_params._overlay_ids[index + 1]
	local pos = batch_params.positions[index + 1]
	if not overlay_id or not pos then return end

	local path = mp.utils.join_path(batch_params._output_dir, "bat_" .. index .. ".bgra")
	local w = batch_params.width
	local h = batch_params.height

	mp.command_native({
		name = "overlay-add",
		id = overlay_id,
		x = pos[1],
		y = pos[2],
		file = path,
		offset = 0,
		fmt = "bgra",
		w = w,
		h = h,
		stride = 4 * w,
	})
	batch_overlay_shown[overlay_id] = true
end

local function bat_clear()
	for id in pairs(batch_overlay_shown) do
		mp.command_native_async({name = "overlay-remove", id = id}, function() end)
	end
	batch_overlay_shown = {}
end

-- =============================================================================
-- 文件清理
-- =============================================================================

local function delete_batch_files(remove_dir)
	if not batch_params then return end
	local dir = batch_params._output_dir
	if remove_dir then
		-- 直接删除整个目录
		if os_name == "windows" then
			local native_dir = dir:gsub("/", "\\")
			mp.command_native({
				name = "subprocess",
				args = {"cmd", "/c", "rmdir", "/s", "/q", native_dir},
				playback_only = false,
				capture_stdout = true,
				capture_stderr = true,
			})
		else
			mp.command_native({
				name = "subprocess",
				args = {"rm", "-rf", dir},
				playback_only = false,
			})
		end
	else
		-- 仅删文件，保留目录
		for i = 0, #batch_params.times - 1 do
			os.remove(mp.utils.join_path(dir, "bat_" .. i .. ".bgra"))
		end
	end
end

-- =============================================================================
-- =============================================================================

local function abort_all()
	for id in pairs(batch_ids) do
		mp.abort_async_command(id)
	end
	batch_ids = {}
	batch_workers = 0
end

-- =============================================================================
-- =============================================================================

local batch_worker

batch_worker = function()
	if not batch_active then
		batch_workers = batch_workers - 1
		return
	end

	if #batch_queue == 0 then
		batch_workers = batch_workers - 1
		if batch_workers <= 0 then
			batch_workers = 0
			if batch_params then
				local total = #batch_params.times
				local completed_count = 0
				for _ in pairs(batch_completed) do completed_count = completed_count + 1 end
				local result = mp.utils.format_json({
					total = total,
					completed = completed_count,
					failed = batch_failed,
					output_dir = batch_params._output_dir,
					width = batch_params.width,
					height = batch_params.height,
				})
				mp.commandv("script-message-to", batch_params.requester, "batch_done", result)
				mp.msg.info("batch done: " .. completed_count .. "/" .. total .. ", failed: " .. batch_failed)
			end
			batch_active = false
		end
		return
	end

	-- 从队列取出任务：尝试均分剩余到 worker 数，但限制单次最大帧数以实现逐步显示
	-- libplacebo 滤镜多输入会冲突？强制单帧
	local max_per_call = batch_params._use_libplacebo and 1 or 2
	local jobs = math.min(math.ceil(#batch_queue / batch_workers), max_per_call)
	if jobs < 1 then jobs = 1 end
	local tasks = {}
	for _ = 1, math.min(jobs, #batch_queue) do
		tasks[#tasks + 1] = table.remove(batch_queue, 1)
	end

	local cmd_args = build_ffmpeg_multi_args(tasks, batch_params.use_keyframe)
	if not cmd_args then
		batch_failed = batch_failed + #tasks
		mp.msg.warn("batch job: no video path available")
		batch_worker()
		return
	end
	local command = build_command(cmd_args)

	local expected_size = batch_params.width * batch_params.height * 4

	local id
	id = mp.command_native_async(command, function(success, result)
		batch_ids[id] = nil

		if not batch_active then
			batch_workers = batch_workers - 1
			return
		end

		-- 检查输出文件
		for _, task in ipairs(tasks) do
			local fpath = mp.utils.join_path(batch_params._output_dir, "bat_" .. task.index .. ".bgra")
			local finfo = mp.utils.file_info(fpath)
			if finfo and finfo.size == expected_size then
				batch_completed[task.index] = true
				bat_draw(task.index)
				local once_json = mp.utils.format_json({
					index = task.index,
					path = fpath,
					width = batch_params.width,
					height = batch_params.height,
				})
				mp.commandv("script-message-to", batch_params.requester, "batch_once", once_json)
			else
				batch_failed = batch_failed + 1
				mp.msg.warn("batch frame " .. task.index .. " extraction failed")
			end
		end

		batch_worker()
	end)
	batch_ids[id] = true
end

-- =============================================================================
-- =============================================================================

function M.batch_extract(params)
	if batch_active then
		M.batch_cancel()
	end

	local ov_ids = parse_overlay_ids()
	local bat_dir = get_bat_dir()

	batch_active = true
	params._overlay_ids = ov_ids
	params._output_dir = bat_dir
	params._vf = build_bat_vf(params.width, params.height)
	params._use_libplacebo = params._vf:find("libplacebo") ~= nil
	batch_params = params
	batch_completed = {}
	batch_failed = 0
	batch_queue = {}
	batch_ids = {}
	batch_overlay_shown = {}
	batch_workers = 0

	if not ensure_dir(bat_dir) then
		mp.msg.error("batch: cannot create output directory: " .. bat_dir)
		batch_active = false
		return
	end

	-- 构建任务队列（暂停恢复：跳过已存在且大小正确的文件）
	for i, time in ipairs(params.times) do
		local index = i - 1
		local fpath = mp.utils.join_path(bat_dir, "bat_" .. index .. ".bgra")
		local finfo = mp.utils.file_info(fpath)
		if finfo and finfo.size == params.width * params.height * 4 then
			batch_completed[index] = true
			bat_draw(index)
			local once_json = mp.utils.format_json({
				index = index,
				path = fpath,
				width = params.width,
				height = params.height,
			})
			mp.commandv("script-message-to", params.requester, "batch_once", once_json)
		else
			table.insert(batch_queue, {index = index, time = time})
		end
	end

	local queued = #batch_queue
	local cached = 0
	for _ in pairs(batch_completed) do cached = cached + 1 end

	if queued == 0 then
		-- 全部已缓存 无需启动 worker
		batch_active = false
		local total = #params.times
		local result = mp.utils.format_json({
			total = total,
			completed = total,
			failed = 0,
			output_dir = bat_dir,
			width = params.width,
			height = params.height,
		})
		mp.commandv("script-message-to", params.requester, "batch_done", result)
		mp.msg.verbose("batch extract: " .. total .. " frames (all cached)")
		return
	end

	mp.msg.info("batch extract: " .. #params.times .. " frames (" .. cached .. " cached, " .. queued .. " queued), workers=" .. options.bat_be_workers)

	-- 启动 worker
	local concurrency = math.max(1, options.bat_be_workers)
	for _ = 1, math.min(concurrency, queued) do
		batch_workers = batch_workers + 1
		batch_worker()
	end
end

function M.batch_pause()
	local was_active = batch_active
	batch_active = false
	abort_all()
	bat_clear()
	if was_active then
		mp.msg.info("batch paused")
	end
end

function M.batch_cancel(remove_dir)
	local was_active = batch_active or batch_params ~= nil
	batch_active = false
	abort_all()
	bat_clear()
	delete_batch_files(remove_dir)
	batch_queue = {}
	batch_completed = {}
	batch_failed = 0
	batch_workers = 0
	batch_params = nil
	if was_active then
		mp.msg.info("batch cancelled" .. (remove_dir and " (rmdir)" or ""))
	end
end

return M
