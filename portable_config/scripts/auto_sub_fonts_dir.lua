--[[
文档_ 无

自动临时加载字体
检测当前播放目录下是否存在 fonts 文件夹，动态修改 --sub-fonts-dir

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
-- 原因：首个添加 --sub-fonts-dir 选项的版本
local min_major = 0
local min_minor = 36
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
	mp.msg.warn("当前mpv版本 (" .. (mpv_ver_curr or "未知") .. ") 低于 " .. min_major .. "." .. min_minor .. "." .. min_patch .. "，已终止缩略图功能。")
	return
end

local fonts_dir_init = mp.get_property_native("sub-fonts-dir")
local fonts_dir_cur = fonts_dir_init
function update_fonts_dir()
	local path = mp.get_property_native("path")
	local fonts_dir = path:match("(.*[/\\])") .. "fonts"
	if fonts_dir == fonts_dir_cur or fonts_dir == fonts_dir_init then
		return
	end
	local read_success = mp.utils.readdir(fonts_dir)
	if not read_success then
		mp.set_property("sub-fonts-dir", fonts_dir_init)
		fonts_dir_cur = fonts_dir_init
		mp.msg.info("回退 --sub-fonts-dir 至初始值")
	else
		mp.set_property("sub-fonts-dir", fonts_dir)
		fonts_dir_cur = fonts_dir
		mp.msg.info("设定 --sub-fonts-dir 至新值【" .. fonts_dir .. "】")
	end
end

mp.register_event("start-file", update_fonts_dir)
