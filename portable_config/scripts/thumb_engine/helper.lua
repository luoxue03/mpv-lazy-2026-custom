local mp = require "mp"
mp.utils = require "mp.utils"

local M = {}

function M.incompat_check(full_str, tar_major, tar_minor, tar_patch)
	if full_str == "unknown" then
		return true
	end

	local clean_ver_str = full_str:gsub("^[^%d]*", "")
	local major, minor, patch = clean_ver_str:match("^(%d+)%.(%d+)%.(%d+)")
	major = tonumber(major)
	minor = tonumber(minor)
	patch = tonumber(patch or 0)
	if major < tar_major then
		return true
	elseif major == tar_major then
		if minor < tar_minor then
			return true
		elseif minor == tar_minor then
			if patch < tar_patch then
				return true
			end
		end
	end

	return false
end

function M.auto_ui_scale()
	local display_w, display_h = mp.get_property_number('display-width', 0), mp.get_property_number('display-height', 0)
	local display_aspect = display_w / display_h or 0
	if display_aspect <= 1 then
		return 1
	end
	if display_aspect >= 2 then
		return tonumber(string.format('%.2f', display_h / 1080))
	end
	if display_w * display_h > 2304000 then
		return tonumber(string.format('%.2f', math.sqrt(display_w * display_h / 2073600)))
	else
		return 1
	end
end

function M.calc_dimensions(state, options)
	local width = state.properties["video-params"] and state.properties["video-params"]["w"]
	local height = state.properties["video-params"] and state.properties["video-params"]["h"]
	if not width or not height then return end
	local auto_scale = tonumber(options.rescale) or 1
	local scale = auto_scale == 0 and (M.auto_ui_scale() or 1) or math.max(auto_scale, 1)

	if width / height > options.max_width / options.max_height then
		state.effective_w = math.floor(options.max_width * scale + 0.5)
		state.effective_h = math.floor(height / width * state.effective_w + 0.5)
	else
		state.effective_h = math.floor(options.max_height * scale + 0.5)
		state.effective_w = math.floor(width / height * state.effective_h + 0.5)
	end
end

function M.real_res(req_w, req_h, filesize, properties)
	local count = filesize / 4
	local diff = (req_w * req_h) - count

	if (properties["video-dec-params"] and properties["video-dec-params"]["rotate"] or 0) % 180 == 90 then
		req_w, req_h = req_h, req_w
	end

	if diff == 0 then
		return req_w, req_h
	else
		local threshold = 5 -- throw out results that change too much
		local long_side, short_side = req_w, req_h
		if req_h > req_w then
			long_side, short_side = req_h, req_w
		end
		for a = short_side, short_side - threshold, -1 do
			if count % a == 0 then
				local b = count / a
				if long_side - b < threshold then
					if req_h < req_w then return b, a else return a, b end
				end
			end
		end
		return nil
	end
end

function M.move_file(from, to, os_name)
	if os_name == "windows" then
		os.remove(to)
	end
	-- move the file because it can get overwritten while overlay-add is reading it, and crash the player
	os.rename(from, to)
end

function M.remove_thumbnail_files(state, options)
	if state.file then
		state.file:close()
		state.file = nil
		state.file_bytes = 0
	end
	os.remove(options.tnpath)
	os.remove(options.tnpath..".bgra")
end

function M.check_new_thumb(options, state, os_name)
	local tmp = options.tnpath..".tmp"
	M.move_file(options.tnpath, tmp, os_name)
	local finfo = mp.utils.file_info(tmp)
	if not finfo then return nil end
	state.spawn_waiting = false
	local w, h = M.real_res(state.effective_w, state.effective_h, finfo.size, state.properties)
	if w then
		M.move_file(tmp, options.tnpath..".bgra", os_name)
		return w, h
	end
	return nil
end

return M
