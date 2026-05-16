--[[
文档_ https://github.com/hooke007/mpv_PlayKit/discussions/615

快捷指令增强
]]

local mp = require "mp"
mp.options = require "mp.options"
mp.utils = require "mp.utils"

local user_opt = {
	load = true,
}
mp.options.read_options(user_opt)

if user_opt.load == false then
	mp.msg.info("脚本已被初始化禁用")
	return
end
-- 原因：stats 新增了第五页
local min_major = 0
local min_minor = 39
local min_patch = 0
local mpv_ver_curr = mp.get_property_native("mpv-version", "unknown")
local function incompat_check(full_str, tar_major, tar_minor, tar_patch)
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
if incompat_check(mpv_ver_curr, min_major, min_minor, min_patch) then
	mp.msg.warn("当前mpv版本 (" .. (mpv_ver_curr or "未知") .. ") 低于 " .. min_major .. "." .. min_minor .. "." .. min_patch .. "，已终止脚本。")
	return
end

local function round(n)
	return n + (2^52 + 2^51) - (2^52 + 2^51)
end

local function ass_escape(s)
	s = s:gsub("\\", "\\\\")
	s = s:gsub("{", "\\{")
	s = s:gsub("}", "\\}")
	return s
end



--
-- 变量预设
--

local plat = mp.get_property_native("platform")

local adevicelist = {}
local target_ao = nil

local chap_skip = false
local chap_keywords = {
	"OP$", "opening$", "オープニング$",
	"ED$", "ending$", "エンディング$",
}

local cmds_sqnum = {}
local prop_tmp = ""

local osm = mp.create_osd_overlay("ass-events")
local osm_showing = false
local osm_timer = nil
local style_generic = "{\\rDefault\\fnConsolas\\fs20\\blur1\\bord2\\1c&HFFFFFF\\3c&H000000}"

local oskn_active = false
local oskn_overlay = mp.create_osd_overlay("ass-events")
oskn_overlay.res_x = 1280
oskn_overlay.res_y = 720
local oskn_hide_timer = nil
local oskn_section = "show-keyname"
local oskn_ignore_keys = { CLOSE_WIN = true, MOUSE_ENTER = true, MOUSE_LEAVE = true, MOUSE_MOVE = true }
local oskn_nav_keys = { UP = true, DOWN = true, LEFT = true, RIGHT = true,
	HOME = true, END = true, PGUP = true, PGDWN = true}
local oskn_special_keys = { ESC = true, TAB = true, ENTER = true, BS = true,
	DEL = true, INS = true, SPACE = true, PRINT = true, IDEOGRAPHIC_SPACE = true }
local oskn_combo_color = "&H9E4A00&" -- 修饰符前缀：深蓝
local oskn_hint = ""
local oskn_replay_cmds = { down = "keydown", up = "keyup", press = "keypress", ["repeat"] = "keypress" }

local marked_aid_A = nil
local marked_aid_B = nil
local mark_aid_reg = false
local merged_aid = false

local ostime_msg = mp.create_osd_overlay("ass-events")
local ostime_showing = false
local ostime_timer = nil
local ostime_style = "{\\rDefault\\fnmpv-osd-symbols\\fs30\\bord2\\an9\\alpha&H80\\1c&H01DBF1\\3c&H000000}"

local osd_hack = mp.create_osd_overlay("ass-events")
local osd_hack_freq = 1/60
osd_hack.data = "{\\rDefault\\an9\\alpha&HFF\\1c&HFFFFFF\\3c&HFFFFFF}" .. "FF"
local osd_hack_timer = nil

local scale_target = 0

local shuffled = false
local shuffling = false
local save_path = mp.command_native({"expand-path", "~~/"}) .. "/playlist_temp.mpl"

local pre_quit = false

local seek_dur_init = 0
local seek_dur_step = 1
local seek_dur = seek_dur_init

local spd_target = 3
local bak_speed = nil
local spd_adapt = false
local spd_iters_max = 10
local spd_delta_max = 0.5
local spd_delta_min = 0.0005

local show_page = 0



--
-- 函数设定
--

local function adevicelist_pre(start)
	mp.set_property("audio-device", adevicelist[start].name)
	adevicelist[start].description = "■ " .. adevicelist[start].description
	local adevice_content = tostring("音频输出设备：\n")
	for items = 1, #adevicelist do
		if string.find(adevicelist[items].name, target_ao, 1, true) then
			if adevicelist[items].name ~= adevicelist[start].name then
				adevice_content = adevice_content .. "□ "
			end
			adevice_content = adevice_content .. adevicelist[items].description .. "\n"
		end
	end
	mp.osd_message(adevice_content, 2)
end
local function adevicelist_pass(start, fin, step)
	while start ~= fin + step do
		if string.find(mp.get_property_native("audio-device"), adevicelist[start].name, 1, true) then
			while true do
				if start + step == 0 then
					start = #adevicelist + 1
				elseif start + step == #adevicelist + 1 then
					start = 0
				end
				start = start + step
				if string.find(adevicelist[start].name, target_ao, 1, true) then
					adevicelist_pre(start)
					return
				end
			end
		end
		start = start + step
	end
end
local function adevicelist_fin(start, fin, step, dynamic)
	if dynamic then
		target_ao = ""
	else
		target_ao = mp.get_property_native("current-ao", "")
	end
	adevicelist_pass(start, fin, step)
end


local function chap_skip_check(_, value)
	if not value then
		return
	end
	for _, words in pairs(chap_keywords) do
		if string.match(value, words) and chap_skip then
			mp.commandv("add", "chapter", 1)
			mp.msg.info("chap_skip_check 跳过章节")
		end
	end
end
local function chap_skip_toggle()
	if chap_skip then
		mp.unobserve_property(chap_skip_check)
		chap_skip = false
		mp.osd_message("[input_plus] " .. "已禁用跳过片头片尾", 1)
		return
	end
	mp.observe_property("chapter-metadata/TITLE", "string", chap_skip_check)
	chap_skip = true
	mp.osd_message("[input_plus] " .. "已启用跳过片头片尾", 1)
end

local function chapter_seek_force(step, nat, uosc)
	if tonumber(step) >= 0 then
		step = 1
	else
		step = -1
	end
	local path = mp.get_property_native("path", "")
	if path == "" then
		return
	end
	local chapter_all = mp.get_property_number("chapters", 0)
	local chapter_act = mp.get_property_number("chapter", 0) + step
	if chapter_act < 0 then
		if uosc then
			mp.commandv("script-binding", "uosc/prev")
		else
			mp.commandv("playlist-prev", "weak")
		end
		if nat then
			mp.add_timeout(0.1, function()
				local path2 = mp.get_property_native("path", "")
				if path2 == path then
					return
				else
					local chapter_act2 = mp.get_property_number("chapters", 0) - 1
					if chapter_act2 <= 0 then
						return
					else
						mp.commandv("set", "chapter", chapter_act2)
					end
				end
			end)
		end
	elseif chapter_act >= chapter_all then
		if uosc then
			mp.commandv("script-binding", "uosc/next")
		else
			mp.commandv("playlist-next", "weak")
		end
	else
		mp.commandv("add", "chapter", step)
	end
end


local function cycle_cmds(...)
	local cmds_list = {...}
	local cur_cmd = table.concat(cmds_list, "|")
	cmds_sqnum[cur_cmd] = (cmds_sqnum[cur_cmd] or 0) % #cmds_list + 1
	mp.command(cmds_list[cmds_sqnum[cur_cmd]])
end


local function import_via_dialog(config)
	if plat ~= "windows" then
		return
	end

	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end

	local res = mp.utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', config.ps_script},
		cancellable = false,
	})

	if was_ontop then mp.set_property_native("ontop", true) end

	if res.status == 0 and res.stdout then
		config.handler(res.stdout)
	end
end
local function get_file_dialog_ps(multiselect)
	return string.format([[& {
		Trap { Write-Error -ErrorRecord $_; Exit 1 }
		Add-Type -AssemblyName PresentationFramework
		$u8 = [System.Text.Encoding]::UTF8
		$out = [Console]::OpenStandardOutput()
		$ofd = New-Object -TypeName Microsoft.Win32.OpenFileDialog
		$ofd.Multiselect = %s
		If ($ofd.ShowDialog() -eq $true) {
			ForEach ($filename in $ofd.FileNames) {
				$u8filename = $u8.GetBytes("$filename`n")
				$out.Write($u8filename, 0, $u8filename.Length)
			}
		}
	}]], multiselect)
end
local import_configs = {
	files = {
		ps_script = get_file_dialog_ps("$true"),
		handler = function(stdout)
			local first_file = true
			for filename in string.gmatch(stdout, '[^\r\n]+') do
				local mode = first_file and "replace" or "append"
				mp.commandv("loadfile", filename, mode)
				first_file = false
			end
		end
	},

	dvd_iso = {
		ps_script = get_file_dialog_ps("$false"),
		handler = function(stdout)
			for filename in string.gmatch(stdout, '[^\r\n]+') do
				mp.commandv("set", "dvd-device", filename)
				mp.commandv("loadfile", "dvd://", "replace")
				break
			end
		end
	},

	bd_iso = {
		ps_script = get_file_dialog_ps("$false"),
		handler = function(stdout)
			for filename in string.gmatch(stdout, '[^\r\n]+') do
				mp.commandv("set", "bluray-device", filename)
				mp.commandv("loadfile", "bd://", "replace")
				break
			end
		end
	},

	audio = {
		ps_script = get_file_dialog_ps("$false"),
		handler = function(stdout)
			for filename in string.gmatch(stdout, '[^\r\n]+') do
				mp.commandv("audio-add", filename, "auto")
			end
		end
	},

	subtitle = {
		ps_script = get_file_dialog_ps("$false"),
		handler = function(stdout)
			for filename in string.gmatch(stdout, '[^\r\n]+') do
				mp.commandv("sub-add", filename, "cached")
			end
		end
	},

	url = {
		ps_script = [[& {
			Trap { Write-Error -ErrorRecord $_; Exit 1 }
			Add-Type -AssemblyName Microsoft.VisualBasic
			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()
			$urlname = [Microsoft.VisualBasic.Interaction]::InputBox("输入地址", "打开", "https://")
			$u8urlname = $u8.GetBytes("$urlname")
			$out.Write($u8urlname, 0, $u8urlname.Length)
		}]],
		handler = function(stdout)
			mp.commandv("loadfile", stdout)
		end
	}
}
local function import_files(iso)
	if plat ~= "windows" then
		return
	end
	local config_map = {
		[0] = import_configs.files,
		[1] = import_configs.dvd_iso,
		[2] = import_configs.bd_iso
	}
	local config = config_map[iso]
	if config then
		import_via_dialog(config)
	end
end
local function import_url()
	import_via_dialog(import_configs.url)
end
local function import_append_aid()
	import_via_dialog(import_configs.audio)
end
local function import_append_sid()
	import_via_dialog(import_configs.subtitle)
end


local function info_get()
	local conf_dir = mp.get_property_bool("config") and mp.command_native({"expand-path", "~~/"}) or "no"
	local osd_dims = mp.get_property_native("osd-dimensions")
	local w_s, h_s = osd_dims["w"] - osd_dims["ml"] - osd_dims["mr"], osd_dims["h"] - osd_dims["mt"] - osd_dims["mb"]
	local cur_name = mp.get_property_osd("media-title") or mp.get_property_osd("filename")
	local vid_params = mp.get_property_native("video-params") or {}
	local w_raw, h_raw, pix_fmt, color_lv = vid_params["w"] or 0, vid_params["h"] or 0, vid_params["hw-pixelformat"] or vid_params["pixelformat"] or "...", vid_params["colorlevels"] or "..."
	local fps_o, fps_t = string.format("%0.3f", mp.get_property_number("container-fps", 0)), string.format("%0.3f", mp.get_property_number("estimated-vf-fps", 0))
	local bitrateV, bitrateA = mp.get_property_number("video-bitrate", 0) / 1000, mp.get_property_number("audio-bitrate", 0) / 1000
	local txt = (
	style_generic.."设置目录： ".."{\\fs18\\1c&H0099FF}"..conf_dir:gsub("\\", "/").."\n"..
	style_generic.."输出尺寸： ".."{\\1c&H0099FF}".."["..w_s.."] x ["..h_s.."]".."\n"..
	style_generic.."解码模式： ".."{\\1c&H0099FF}"..mp.get_property_native("hwdec-current", "...").."\n"..
	style_generic.."显示同步： ".."{\\1c&H0099FF}"..mp.get_property_native("video-sync", "...").."\n"..
	style_generic.."丢帧暂计： ".."{\\1c&H0099FF}"..mp.get_property_number("frame-drop-count", 0).."\n"..
	style_generic.."当前文件： ".."{\\fs18\\1c&H0099FF}"..cur_name:gsub("\\n", " "):gsub("\\$", ""):gsub("{","\\{").."\n"..
	style_generic.."视频 ┓".."\n"..
	style_generic.."-   输出： ".."{\\1c&H03A89E}"..mp.get_property_native("current-vo", "...").."\n"..
	style_generic.."-   编码： ".."{\\1c&H03A89E}"..mp.get_property_native("video-codec", "...").."\n"..
	style_generic.."-   尺寸： ".."{\\1c&H03A89E}".."["..w_raw.."] x ["..h_raw.."]".."\n"..
	style_generic.."-   像素： ".."{\\1c&H03A89E}"..pix_fmt.."\n"..
	style_generic.."-   动态： ".."{\\1c&H03A89E}"..color_lv.."\n"..
	style_generic.."-   帧率： ".."{\\1c&H03A89E}"..fps_o.." FPS（原始） "..fps_t.." FPS（目标）".."\n"..
	style_generic.."-   码率： ".."{\\1c&H03A89E}"..bitrateV.." kbps（当前）".."\n"..
	style_generic.."音频 ┓".."\n"..
	style_generic.."-   输出： ".."{\\1c&H9EA803}"..mp.get_property_native("current-ao", "...").."【设备】"..mp.get_property_native("audio-device", "...").."\n"..
	style_generic.."-   编码： ".."{\\1c&H9EA803}"..mp.get_property_native("audio-codec", "...").."\n"..
	style_generic.."-   码率： ".."{\\1c&H9EA803}"..bitrateA.." kbps（当前）".."\n"..
	style_generic.."着色器列： ".."{\\fs18\\1c&HFF8821}"..mp.get_property_osd("glsl-shaders"):gsub(":\\", "/"):gsub(":/", "/"):gsub("\\", "/"):gsub(";", " "):gsub(",", " "):gsub(":", " ").."\n"..
	style_generic.."视频滤镜： ".."{\\fs18\\1c&HFF8821}"..mp.get_property_osd("vf"):gsub("%(empty%)", ""):gsub(" %[", "%["):gsub("%]\n", "%] "):gsub(" %(disabled%)", "（禁用）").."\n"..
	style_generic.."音频滤镜： ".."{\\fs18\\1c&HFF8821}"..mp.get_property_osd("af"):gsub("%(empty%)", ""):gsub(" %[", "%["):gsub("%]\n", "%] "):gsub(" %(disabled%)", "（禁用）")
	)
	return tostring(txt)
end
local function info_toggle()
	if osm_showing then
		osm:remove()
		osm_timer:kill()
		osm_showing = false
		return
	end
	osm.data = info_get()
	osm:update()
	osm_showing = true
	osm_timer = mp.add_periodic_timer(0.5, function()
		if not osm_showing then
			osm_timer:kill()
		else
			osm.data = info_get()
			osm:update()
		end
	end)
end


local function oskn_get_color(name)
	if name:match("^F%d+$") then return "&H7A2E80&" end      -- 功能键：紫色
	if name:match("^KP") then return "&H7A2E80&" end         -- 小键盘：紫色
	if oskn_nav_keys[name] then return "&H2E8B00&" end       -- 导航键：深绿
	if name:match("^MBTN") or name:match("^MOUSE_BTN")
		or name:match("^WHEEL_") or name:match("^AXIS_") then
		return "&H998800&"                                   -- 鼠标：深青
	end
	if name:match("^GAMEPAD_") then return "&H2E6B8B&" end   -- 手柄：深黄
	if name:match("^TABLET_") then return "&H2E6B8B&" end    -- 数位板：深黄
	if name:match("^XF86_") then return "&H6B238E&" end      -- 多媒体（废弃）：深紫
	if oskn_special_keys[name] then return "&H0048B8&" end   -- 特殊键：深橙
	-- 多媒体/遥控器键（全大写且无下划线前缀已被上方匹配）
	if name:match("^%u[%u_]+$") and #name > 2 and name ~= "SHARP" then
		return "&H6B238E&"                                   -- 多媒体键：深紫
	end
	return "&H333333&"                                       -- 常规字符：深灰
end
local function oskn_rounded_rect(w, h, r)
	local c = 0.5519 * r
	return table.concat({
		string.format("m %d 0", r),
		string.format("l %d 0", w - r),
		string.format("b %d 0 %d %d %d %d", w - r + c, w, r - c, w, r),
		string.format("l %d %d", w, h - r),
		string.format("b %d %d %d %d %d %d", w, h - r + c, w - r + c, h, w - r, h),
		string.format("l %d %d", r, h),
		string.format("b %d %d 0 %d 0 %d", r - c, h, h - r + c, h - r),
		string.format("l 0 %d", r),
		string.format("b 0 %d %d 0 %d 0", r - c, r - c, r),
	}, " ")
end
-- 拆分组合键的修饰符前缀和基础键
local function oskn_split_combo(name)
	local mods, base = name:match("^(.*%+)([^+]+)$")
	if mods and (mods:find("Ctrl%+") or mods:find("Alt%+")
		or mods:find("Shift%+") or mods:find("Meta%+")) then
		return mods, base
	end
	return nil, name
end
local function oskn_find_toggle_keys()
	local keys = {}
	local seen = {}
	local bindings = mp.get_property_native("input-bindings", {})
	for _, b in ipairs(bindings) do
		if b.cmd and b.cmd:find("input_test_toggle") and not seen[b.key] then
			seen[b.key] = true
			keys[#keys + 1] = b.key
		end
	end
	return keys
end
local function oskn_show(name)
	if oskn_hide_timer then
		oskn_hide_timer:kill()
	end

	local mods, base = oskn_split_combo(name)
	local base_color = oskn_get_color(base)

	local escaped_text
	if mods then
		escaped_text = "{\\1c" .. oskn_combo_color .. "}" .. ass_escape(mods) .. "{\\1c" .. base_color .. "}" .. ass_escape(base)
	else
		escaped_text = "{\\1c" .. base_color .. "}" .. ass_escape(name)
	end

	local fs = 64
	local char_count = #name
	local text_w = math.max(char_count * fs * 0.55, fs)
	local pad_x, pad_y = 36, 18
	local w = text_w + pad_x * 2
	local h = fs + pad_y * 2
	local r = 16

	local cx, cy = oskn_overlay.res_x / 2, oskn_overlay.res_y / 2

	local bg = string.format(
		"{\\rDefault\\an5\\pos(%d,%d)\\p1\\1c&HE8E8E8&\\1a&H18&\\bord0\\shad0}%s",
		cx, cy, oskn_rounded_rect(w, h, r)
	)
	local txt = string.format(
		"{\\rDefault\\an5\\pos(%d,%d)\\fs%d\\b1\\bord0\\shad0}%s",
		cx, cy, fs, escaped_text
	)

	oskn_overlay.data = oskn_hint .. "\n" .. bg .. "\n" .. txt
	oskn_overlay:update()

	oskn_hide_timer = mp.add_timeout(2, function()
		oskn_overlay.data = oskn_hint
		oskn_overlay:update()
		oskn_hide_timer = nil
	end)
end
local function oskn_deactivate()
	mp.input_disable_section(oskn_section)
	mp.input_define_section(oskn_section, "")
	mp.remove_key_binding("oskn-handler")

	if oskn_hide_timer then
		oskn_hide_timer:kill()
		oskn_hide_timer = nil
	end
	oskn_overlay:remove()
end
local function oskn_on_key(info)
	local name = info.key_name or info.key_text or "?"

	-- ESC 作为回退备用按键
	if name == "ESC" and (info.event == "down" or info.event == "press") then
		oskn_active = false
		oskn_deactivate()
		return
	end

	-- 黑名单按键：不显示且到达原有绑定
	if oskn_ignore_keys[name] then
		local cmd = oskn_replay_cmds[info.event]
		if cmd and name then
			mp.input_disable_section(oskn_section)
			mp.commandv(cmd, name)
			mp.add_timeout(0, function()
				if oskn_active then
					mp.input_enable_section(oskn_section, "exclusive")
				end
			end)
		end
		return
	end

	if (info.event == "down" or info.event == "press") then
		oskn_show(name)
	end
end
local function oskn_build_section()
	local sn = mp.get_script_name()
	local toggle_keys = oskn_find_toggle_keys()
	local lines = {
		"any_unicode script-binding " .. sn .. "/oskn-handler",
		"unmapped script-binding " .. sn .. "/oskn-handler",
	}
	for _, key in ipairs(toggle_keys) do
		table.insert(lines, key .. " script-binding " .. sn .. "/input_test_toggle") -- 关联激活的快捷指令
	end
	return table.concat(lines, "\n")
end
local function oskn_activate()
	mp.add_key_binding(nil, "oskn-handler", oskn_on_key,
		{complex = true, repeatable = true})

	mp.input_define_section(oskn_section, oskn_build_section(), "force")
	mp.input_enable_section(oskn_section, "exclusive")

	local toggle_keys = oskn_find_toggle_keys()
	local exit_text = "ESC"
	if #toggle_keys > 0 then
		exit_text = table.concat(toggle_keys, " / ") .. " / ESC"
	end
	oskn_hint = "{\\rDefault\\an1\\fs58\\blur1\\bord2\\shad0\\1c&HFFFFFF&\\3c&H000000&}按键测试模式 (" .. exit_text .. " 退出)"
	oskn_overlay.data = oskn_hint
	oskn_overlay:update()
end
local function oskn_toggle()
	oskn_active = not oskn_active
	if oskn_active then
		oskn_activate()
	else
		oskn_deactivate()
	end
end


local function mark_aid_check()
	if not mark_aid_reg then return end
	if marked_aid_A ~= nil or marked_aid_B ~= nil then
		mp.command("no-osd set lavfi-complex \"\"")
		merged_aid = false
		marked_aid_A, marked_aid_B = nil, nil
		mp.osd_message("[input_plus] " .. "已取消并轨和标记", 1)
		mark_aid_reg = false
	end
	mp.msg.info("mark_aid_check 重置并轨和标记")
end
local function mark_aid_reset()
	mp.command("no-osd set lavfi-complex \"\"")
	merged_aid = false
	marked_aid_A, marked_aid_B = nil, nil
	mp.osd_message("[input_plus] " .. "已取消并轨和标记", 1)
	if mark_aid_reg then
		mp.unregister_event(mark_aid_check)
		mark_aid_reg = false
	end
end
local function mark_aid_A()
	marked_aid_A = mp.get_property_number("aid", 0)
	if marked_aid_A == 0
	then
		mp.osd_message("[input_plus] " .. "当前音轨无效", 1)
		marked_aid_A = nil
	else
		mp.osd_message("[input_plus] " .. "预标记当前音轨序列 " .. marked_aid_A .. " 为并行轨A", 1)
	end
	if mark_aid_reg then
		return
	else
		mp.register_event("end-file", mark_aid_check)
		mark_aid_reg = true
	end
end
local function mark_aid_B()
	marked_aid_B = mp.get_property_number("aid", 0)
	if marked_aid_B == 0
	then
		mp.osd_message("[input_plus] " .. "当前音轨无效", 1)
		marked_aid_B = nil
	else
		mp.osd_message("[input_plus] " .. "预标记当前音轨序列 " .. marked_aid_B .. " 为并行轨B", 1)
	end
	if mark_aid_reg then
		return
	else
		mp.register_event("end-file", mark_aid_check)
		mark_aid_reg = true
	end
end
local function mark_aid_merge()
	if marked_aid_A == marked_aid_B or marked_aid_A == nil or marked_aid_B == nil
	then
		mp.osd_message("[input_plus] " .. "无效的AB音轨", 1)
		marked_aid_A, marked_aid_B = nil, nil
	else
		mp.command("set lavfi-complex \"[aid" .. marked_aid_A .. "] [aid" .. marked_aid_B .. "] amix [ao]\"")
		mp.osd_message("[input_plus] " .. "已合并AB音轨", 1)
		merged_aid = true
	end
end
local function mark_aid_fin()
	if merged_aid then
		mark_aid_reset()
		mp.commandv("set", "aid", "auto")
		return
	end
	if marked_aid_A == nil then
		mark_aid_A()
		return
	end
	if marked_aid_B == nil then
		mark_aid_B()
		return
	end
	mark_aid_merge()
end


local function draw_ostime()
	local ostime = os.date("*t")
	ostime_msg.data = ostime_style .. "\238\128\134 " .. string.format("%02d:%02d:%02d", ostime.hour, ostime.min, ostime.sec)
	ostime_msg:update()
end
local function ostime_toggle()
	if ostime_showing then
		ostime_timer:kill()
		ostime_msg:remove()
		ostime_showing = false
	else
		ostime_timer = mp.add_periodic_timer(1, draw_ostime)
		ostime_showing = true
	end
end
local function ostime_display()
	if ostime_showing then
		return
	end
	draw_ostime()
	mp.add_timeout(1, function()
		ostime_msg:remove()
		draw_ostime()
	end)
	mp.add_timeout(2, function()
		ostime_msg:remove()
	end)
end


local function update_osd()
	osd_hack:update()
end
local function osd_hack_set(num, freq)
	num = tonumber(num) or -1
	if num ~= 0  and num ~= 1 then
		return
	end
	freq = tonumber(freq) or osd_hack_freq
	if freq <= 0 or freq > 1 then
		freq = osd_hack_freq
	end

	if osd_hack_timer == nil then
		if num == 0 then
			return
		elseif num == 1 then
			osd_hack_freq = freq
			osd_hack_timer = mp.add_periodic_timer(osd_hack_freq, update_osd)
			mp.msg.info("update_osd 已启动")
		end
	else
		if freq == osd_hack_freq then
			if num == 0 then
				osd_hack_timer:stop()
				mp.msg.info("update_osd 已暂停")
			elseif num == 1 then
				osd_hack_timer:resume()
				mp.msg.info("update_osd 已恢复")
			end
		else
			osd_hack_freq = freq
			osd_hack_timer:kill()
			osd_hack_timer = nil
			if num == 0 then
				mp.msg.info("update_osd 已终止")
				return
			elseif num == 1 then
				osd_hack_timer = mp.add_periodic_timer(osd_hack_freq, update_osd)
				mp.msg.info("update_osd 已重启")
			end
		end
	end
end


local function scale_recal(pct)
	local w_dp, h_dp = mp.get_property_number("display-width", 0), mp.get_property_number("display-height", 0)
	local w_vf, h_vf = mp.get_property_number("dwidth", 0), mp.get_property_number("dheight", 0)
	local scale_win = mp.get_property_number("current-window-scale", 0)
	local scale_shift = mp.get_property_number("display-hidpi-scale", 1)
	if w_dp == 0 or w_vf == 0 or scale_win == 0 then
		mp.msg.warn("scale_recal 缺乏必要条件")
		scale_target = 0
		return
	end
	scale_target = tonumber(string.format("%.3f", math.sqrt((w_dp * h_dp * pct * 0.01) / (w_vf * h_vf)) / scale_shift))
end
local function window_mini(alt1, alt2)
	mp.set_property_bool("fullscreen", false)
	if alt1 then
		mp.set_property_bool("border", false)
	end
	mp.set_property_number("current-window-scale", scale_target)
	mp.set_property_bool("auto-window-resize", false)
	mp.set_property_bool("keepaspect-window", false)
	if alt2 then
		mp.set_property_bool("ontop", true)
	end
end
local function pip_dummy(pct)
	if mp.get_property_native("idle-active") or not mp.get_property_native("vid") then
		mp.msg.warn("pip_dummy 无法在当前状态使用")
		return
	end
	scale_recal(pct)
	if scale_target == 0 then
		return
	end
	window_mini(true, true)
	mp.msg.info("pip_dummy 已尝试应用")
end


local function show_playlist_shuffle()
	mp.add_timeout(0.1, function()
		local shuffle_msg = mp.command_native({"expand-text", "${playlist}"})
		shuffling = false
		mp.osd_message(shuffle_msg, 2)
	end)
end
local function playlist_order(mode, re)
	if shuffling then
		mp.msg.info("playlist_order 已阻止高频洗牌")
		return
	end
	if mp.get_property_number("playlist-count") <= 2 then
		mp.osd_message("[input_plus] " .. "播放列表中的条目数量不足", 1)
		return
	end
	shuffling = true
	if mode == 0 then
		if not shuffled then
			mp.command("playlist-shuffle")
			shuffled = true
			if re then
				mp.commandv("playlist-play-index", 0)
			end
			show_playlist_shuffle()
		else
			mp.command("playlist-unshuffle")
			shuffled = false
			if re then
				mp.commandv("playlist-play-index", 0)
			end
			show_playlist_shuffle()
		end
	elseif mode == 1 then
		if shuffled then
			mp.command("playlist-unshuffle")
			mp.command("playlist-shuffle")
			if re then
				mp.commandv("playlist-play-index", 0)
			end
			show_playlist_shuffle()
		else
			mp.command("playlist-shuffle")
			shuffled = true
			if re then
				mp.commandv("playlist-play-index", 0)
			end
			show_playlist_shuffle()
		end
	end
end
local function playlist_random()
	local range = mp.get_property_number("playlist-count", 0)
	if range <= 2 then
		mp.msg.info("playlist_random 播放列表的条目数量未超过2")
		return
	end
	local pos = mp.get_property_number("playlist-pos-1", 0)
	local pos_nxt = math.random(1, range)
	while pos_nxt == pos do
		pos_nxt = math.random(1, range)
	end
	mp.commandv("set", "playlist-pos-1", pos_nxt)
end
local function playlist_tmp_save()
	local item_num = mp.get_property_number("playlist-count", 0)
	if item_num == 0 then
		mp.osd_message("[input_plus] " .. "播放列表中无文件", 1)
		return
	end
	local file, err = io.open(save_path, "w")
	if not file then
		mp.osd_message("[input_plus] " .. "播放列表保存失败: " .. (err or ""), 1)
		return
	end
	file:write("#EXTM3U\n\n")
	local Nn = 0
	while Nn < item_num do
		local save_item = mp.get_property("playlist/"..Nn.."/filename")
		file:write(save_item, "\n")
		Nn = Nn+1
	end
	mp.osd_message("[input_plus] " .. "已保存至临时播放列表", 1)
	mp.msg.info("playlist_tmp_save 主设置文件夹/playlist_temp.mpl")
	file:close()
end
local function playlist_tmp_load()
	mp.commandv("loadlist", save_path, "replace")
	if mp.get_property_number("playlist-count", 0) == 0 then
		mp.osd_message("[input_plus] " .. "临时播放列表加载失败", 1)
	else
		mp.osd_message(mp.command_native({"expand-text", "${playlist}"}), 2)
	end
end


local function quit_real()
	if pre_quit then
		mp.command("quit")
	else
		mp.osd_message("再次执行以确认退出", 1.5)
		pre_quit = true
		mp.add_timeout(1.5, function()
			pre_quit = false
			mp.msg.verbose("quit_real 检测到误触退出键")
		end)
	end
end
local function quit_wait()
	if pre_quit then
		pre_quit = false
		return
	else
		pre_quit = true
		mp.osd_message("即将退出，再次执行以取消", 3)
		mp.add_timeout(3, function()
			if pre_quit then
				mp.command("quit")
			else
				mp.osd_message("已取消退出", 0.5)
				return
			end
		end)
	end
end


-- 另一种版本 https://github.com/mpv-player/mpv/issues/11589#issuecomment-1513535980
local function acc_seeking(back, flag)
	seek_dur = seek_dur + seek_dur_step
	if not back then
		mp.command("seek " .. seek_dur .. " " .. flag)
	else
		mp.command("seek -" .. seek_dur .. " " .. flag)
	end
end
local function seek_acc(back, alt)
	local function seek_acc_sub(flag_complex)
		local evt = flag_complex.event
		if evt == "up" then
			seek_dur = seek_dur_init
			return
		end
		if evt ~= "repeat" then
			return
		end
		local mode = alt and "exact" or "keyframes"
		acc_seeking(back, mode)
	end
	return seek_acc_sub
end


local function sids_sec_swap()
	local sid_main = mp.get_property_number("sid", 0)
	local sid_sec = mp.get_property_number("secondary-sid", 0)
	if sid_main == 0 and sid_sec == 0 then
		return
	end
	mp.set_property_number("sid", 0)
	mp.set_property_number("secondary-sid", 0)
	mp.set_property_number("sid", sid_sec)
	mp.set_property_number("secondary-sid", sid_main)
end


local function speed_auto(num, any)
	if any then
		num = spd_target
	end
	local function speed_auto_sub(flag_complex)
		local evt = flag_complex.event
		if evt == "down" then
			mp.set_property_number("speed", num)
			mp.msg.verbose("speed_auto 变速播放中")
		elseif evt == "up" then
			mp.set_property_number("speed", 1)
			mp.msg.verbose("speed_auto 已恢复常速")
		end
	end
	return speed_auto_sub
end

local function speed_recover()
	if mp.get_property_number("speed") ~= 1 then
		bak_speed = mp.get_property_number("speed")
		mp.command("set speed 1")
	else
		if bak_speed == nil then
			bak_speed = 1
		end
		mp.command("set speed " .. bak_speed)
	end
end
local function speed_scale(rat, fact)
	local spd_scale, spd_delta = nil, nil
	for _, i in ipairs({fact, fact-1, fact+1}) do
		spd_scale = rat * i / math.floor(i * rat + 0.5)
		spd_delta = math.abs(spd_scale - 1)
		if spd_delta < spd_delta_min then
			mp.msg.info("speed_sync_toggle 目标速度为1")
			return 1
		elseif spd_delta <= spd_delta_max then
			mp.msg.info("speed_sync_toggle 目标速度为" .. spd_scale)
			return spd_scale
		end
	end
end
local function speed_adaptive()
	local fps_raw = mp.get_property_number("container-fps", 0)
	local fps_vf = mp.get_property_number("estimated-vf-fps", 0)
	local fps_dp = mp.get_property_number("display-fps", 0)
	local spd_cur = mp.get_property_number("speed", 1)
	if (fps_raw == 0 or fps_dp == 0 or fps_raw > 32 or math.abs(fps_vf - fps_raw) > 0.5) then
		mp.msg.warn("speed_sync_toggle 存在例外的FPS情况")
		return
	end
	for i = 1, spd_iters_max do
		local spd_result = speed_scale(fps_dp / fps_raw, i)
		if spd_result then
			if math.abs(spd_result - spd_cur) < 0.0001 then
				break
			else
				mp.set_property("speed", spd_result)
				mp.msg.info("speed_sync_toggle 设定当前速度为" .. spd_result)
				break
			end
		end
	end
end
local function speed_sync_toggle()
	spd_adapt = not spd_adapt
	if spd_adapt then
		speed_adaptive()
		mp.osd_message("[input_plus] " .. "已启用速度自适应", 1)
		mp.register_event("playback-restart", speed_adaptive)
	else
		mp.unregister_event(speed_adaptive)
		mp.set_property_number("speed", 1)
		mp.osd_message("[input_plus] " .. "已禁用速度自适应", 1)
		return
	end
end


local function stats_cycle(num_init, num_end)
	if num_init < 0 or num_init > 5 then
		num_init = 1
	end
	if num_end < num_init then
		num_end = num_init
	end
	if num_end > 5 then
		num_end = 5
	end
	if show_page + 1 > num_end then
		show_page = num_init - 1
	end
	show_page = show_page + 1
	mp.commandv("script-binding", "display-page-" .. show_page)
end


local function track_seek(id, num)
	mp.command("add " .. id .. " " .. num)
	if mp.get_property_number(id, 0) == 0 then
		mp.command("add " .. id .. " " .. num)
		if mp.get_property_number(id, 0) == 0 then
			mp.osd_message("[input_plus] " .. "无可用" .. id, 1)
		end
	end
end


local function track_refresh(id)
	local current_id = mp.get_property_number(id, 0)
	if current_id == 0 then
		mp.msg.warn("track_refresh 当前" .. id .. "无效")
		return
	end
	mp.set_property_number(id, 0)
	mp.set_property_number(id, current_id)
end


-- 另一种实现 https://github.com/mpv-player/mpv/pull/11444#issuecomment-1469229943
local function volume2db(vol)
	return 60.0 * math.log(vol / 100.0) / math.log(10.0)
end
-- https://github.com/mpv-player/mpv/blob/051ba909b4107240d643e4793efa2ceb714fd1b4/player/audio.c#L175
local function db2volume(db)
	return math.exp(math.log(10.0) * (db / 60.0 + 2))
end
local function volume_add(diff)
	local gain = round(volume2db(mp.get_property_number("volume"))) + diff
	local cap = mp.get_property_number("volume-max")
	if db2volume(gain) > cap then
		gain = volume2db(cap)
	elseif db2volume(gain) < 10 then
		gain = volume2db(10)
	end
	mp.set_property_number("volume", db2volume(gain))
	mp.osd_message("[input_plus] " .. string.format("音量增益： %+.2f dB", gain))
end


local function prop_hold(prop)
	local function prop_auto(flag_complex)
		local evt = flag_complex.event
		if evt == "down" then
			prop_tmp = mp.get_property_native(prop, "")
			mp.set_property_native(prop, "")
			mp.msg.verbose("prop_hold 已清零 " .. prop)
		elseif evt == "up" then
			mp.set_property_native(prop, prop_tmp)
			mp.msg.verbose("prop_hold 已恢复")
		end
	end
	return prop_auto
end


local function update_shader_param(prefix, shader, param, val, def, min, max)

	if prefix == "set" then
		if shader == "_all_" then
			mp.command("change-list glsl-shader-opts append " .. param .. "=" .. val)
		else
			mp.command("change-list glsl-shader-opts append " .. shader .. "/" .. param .. "=" .. val)
		end

	elseif prefix == "add" then
		local glsl_opts = mp.get_property("glsl-shader-opts", "")
		local glsl_target = shader .. "/" .. param
		local glsl_target2 = param
		local function extract(input, key)
			local pattern = "[,]*" .. key .. "=([^,]+)"
			local value = input:match(pattern)
			return value
		end
		val = tonumber(val) or 0
		def = tonumber(def) or 0
		local val_cur
		if shader == "_all_" then
			val_cur = extract(glsl_opts, glsl_target2) or def
		else
			val_cur = extract(glsl_opts, glsl_target) or def
		end
		min = tonumber(min) or -10000
		max = tonumber(max) or 10000
		local val_nxt = val_cur + val
		if val_nxt > max then
			val_nxt = max
		elseif val_nxt < min then
			val_nxt = min
		end
		if shader == "_all_" then
			mp.command("change-list glsl-shader-opts append " .. param .. "=" .. val_nxt)
		else
			mp.command("change-list glsl-shader-opts append " .. shader .. "/" .. param .. "=" .. val_nxt)
		end

	end

end



--
-- 特殊
--

local function update_var(var, val)
	local msg_info_pre = "[input_plus] "
	local msg_info = "内部变量更新"

	if var == "spd_target" then
		mp.remove_key_binding("speed_autox")
		if tonumber(val) <=0 then
			val = 0.1
		end
		spd_target = tonumber(val)
		msg_info = "自定义目标速度 " .. val
		mp.osd_message(msg_info_pre .. msg_info, 1)
		mp.msg.info(msg_info)
		mp.add_key_binding(nil, "speed_autox", speed_auto(nil, spd_target), {complex = true})

	elseif var == "seek_dur_step" then
		if tonumber(val) <=0 then
			val = 0.1
		end
		seek_dur_step = tonumber(val)
		msg_info = "自定义跳转步长增量 " .. val
		mp.osd_message(msg_info_pre .. msg_info, 1)
		mp.msg.info(msg_info)

	end
end

local function lazy_helper(link)
	local param = ""
	if plat == "windows" then
		param = 'no-osd run cmd /c start "" "' .. link .. '"'
	elseif plat == "darwin" then
		param = "no-osd run /bin/sh -c \"open '" .. link .. "' &\""
	elseif plat == "linux" then
		param = "no-osd run /bin/sh -c \"xdg-open '" .. link .. "' &\""
	else
		return
	end
	return param
end
local function lazy_helper_main(index)
	index = tonumber(index)
	local cmd = ""

	if index == 0 then -- project
		cmd = lazy_helper("https://github.com/hooke007/mpv_PlayKit")
	elseif index == 1 then -- mpv manual
		cmd = lazy_helper("https://mpv.io/manual/master/")
	elseif index == 2 then -- mpv manual cn
		cmd = lazy_helper("https://hooke007.github.io/official_man/mpv.html")
	elseif index == 3 then -- faq
		cmd = lazy_helper("https://github.com/hooke007/mpv_PlayKit/wiki/0_FAQ")
	elseif index == 4 then -- filter
		cmd = lazy_helper("https://github.com/hooke007/mpv_PlayKit/wiki/3_FILTER")
	elseif index == 5 then -- shader
		cmd = lazy_helper("https://github.com/hooke007/mpv_PlayKit/wiki/4_GLSL")
	end

	if cmd ~= "" then
		mp.command(cmd)
	end
end



--
-- 键位绑定
--

mp.add_key_binding(nil, "adevice_back", function()
	adevicelist = mp.get_property_native("audio-device-list") adevicelist_fin(#adevicelist, 1, -1) end)
mp.add_key_binding(nil, "adevice_next", function()
	adevicelist = mp.get_property_native("audio-device-list") adevicelist_fin(1, #adevicelist, 1) end)
mp.add_key_binding(nil, "adevice_all_back", function()
	adevicelist = mp.get_property_native("audio-device-list") adevicelist_fin(#adevicelist, 1, -1, true) end)
mp.add_key_binding(nil, "adevice_all_next", function()
	adevicelist = mp.get_property_native("audio-device-list") adevicelist_fin(1, #adevicelist, 1, true) end)

mp.add_key_binding(nil, "chap_skip_toggle", chap_skip_toggle)

mp.add_key_binding(nil, "chapter_back", function() chapter_seek_force(-1) end)
mp.add_key_binding(nil, "chapter_back_nat", function() chapter_seek_force(-1, true) end)
mp.add_key_binding(nil, "chapter_next", function() chapter_seek_force(1) end)
mp.register_script_message("chapter-useek", function(dir, nat) chapter_seek_force(dir, nat, true) end)

mp.add_key_binding(nil, "import_files", function() import_files(0) end)
mp.add_key_binding(nil, "import_iso_dvd", function() import_files(1) end)
mp.add_key_binding(nil, "import_iso_bd", function() import_files(2) end)
mp.add_key_binding(nil, "import_url", import_url)
mp.add_key_binding(nil, "import_append_aid", import_append_aid)
mp.add_key_binding(nil, "import_append_sid", import_append_sid)

mp.add_key_binding(nil, "info_toggle", info_toggle)

mp.add_key_binding(nil, "input_test_toggle", oskn_toggle)

mp.add_key_binding(nil, "mark_aid_A", mark_aid_A)
mp.add_key_binding(nil, "mark_aid_B", mark_aid_B)
mp.add_key_binding(nil, "mark_aid_merge", mark_aid_merge)
mp.add_key_binding(nil, "mark_aid_reset", mark_aid_reset)
mp.add_key_binding(nil, "mark_aid_fin", mark_aid_fin)

mp.add_key_binding(nil, "ostime_display", ostime_display)
mp.add_key_binding(nil, "ostime_toggle", ostime_toggle)

mp.add_key_binding(nil, "pip_dummy", function() pip_dummy(20) end)
mp.register_script_message("pip_dummy_pct", function(pct) pip_dummy(tonumber(pct)) end)

mp.add_key_binding(nil, "playlist_order_0", function() playlist_order(0) end)
mp.add_key_binding(nil, "playlist_order_0r", function() playlist_order(0, true) end)
mp.add_key_binding(nil, "playlist_order_1", function() playlist_order(1) end)
mp.add_key_binding(nil, "playlist_order_1r", function() playlist_order(1, true) end)
mp.add_key_binding(nil, "playlist_random", playlist_random)
mp.add_key_binding(nil, "playlist_tmp_save", playlist_tmp_save)
mp.add_key_binding(nil, "playlist_tmp_load", playlist_tmp_load)

mp.add_key_binding(nil, "quit_real", quit_real)
mp.add_key_binding(nil, "quit_wait", quit_wait)

mp.add_key_binding(nil, "seek_acc", seek_acc(false, false), {complex = true})
mp.add_key_binding(nil, "seek_acc_back", seek_acc(true, false), {complex = true})
mp.add_key_binding(nil, "seek_acc_alt", seek_acc(false, true), {complex = true})
mp.add_key_binding(nil, "seek_acc_back_alt", seek_acc(true, true), {complex = true})

mp.add_key_binding(nil, "sids_sec_swap", sids_sec_swap)

mp.add_key_binding(nil, "speed_auto", speed_auto(2), {complex = true})
mp.add_key_binding(nil, "speed_auto_bullet", speed_auto(0.5), {complex = true})
mp.add_key_binding(nil, "speed_autox", speed_auto(_, spd_target), {complex = true})
mp.add_key_binding(nil, "speed_recover", speed_recover)

mp.add_key_binding(nil, "speed_sync_toggle", speed_sync_toggle)

mp.register_script_message("cycle-stats", function(pg_init, pg_end) stats_cycle(tonumber(pg_init), tonumber(pg_end)) end)

mp.add_key_binding(nil, "trackA_back", function() track_seek("aid", -1) end)
mp.add_key_binding(nil, "trackA_next", function() track_seek("aid", 1) end)
mp.add_key_binding(nil, "trackS_back", function() track_seek("sid", -1) end)
mp.add_key_binding(nil, "trackS_next", function() track_seek("sid", 1) end)
mp.add_key_binding(nil, "trackV_back", function() track_seek("vid", -1) end)
mp.add_key_binding(nil, "trackV_next", function() track_seek("vid", 1) end)

mp.add_key_binding(nil, "trackA_refresh", function() track_refresh("aid") end)
mp.add_key_binding(nil, "trackS_refresh", function() track_refresh("sid") end)
mp.add_key_binding(nil, "trackV_refresh", function() track_refresh("vid") end)

mp.add_key_binding(nil, "volume_db_dec", function() volume_add(-1) end, {repeatable = true})
mp.add_key_binding(nil, "volume_db_inc", function() volume_add(1) end, {repeatable = true})

mp.add_key_binding(nil, "af_hold", prop_hold("af"), {complex = true})
mp.add_key_binding(nil, "vf_hold", prop_hold("vf"), {complex = true})
mp.add_key_binding(nil, "glsl_hold", prop_hold("glsl-shaders"), {complex = true})

mp.register_script_message("glsl-param", function(prefix, shader, param, val, def, min, max)
	update_shader_param(prefix, shader, param, val, def, min, max) end)

mp.register_script_message("cycle-cmds", cycle_cmds)

mp.register_script_message("update-osd", function(num, freq) osd_hack_set(num, freq) end)

mp.register_script_message("update-var", function(var, val) update_var(var, val) end)

mp.register_script_message("lazy-helper", function(index) lazy_helper_main(index) end)
