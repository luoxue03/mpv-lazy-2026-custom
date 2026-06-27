-- rtx_hdr_toggle.lua
-- RTX Video HDR 开关：通过 vf pre 命令挂载 d3d11vpp=nvidia-true-hdr，
-- 与补帧/超分的 vf set 互不干扰（vf pre 在主列表之前，vf set 清不到它）；
-- 同步 target-colorspace-hint 让显示器切换 HDR。
-- 前置条件：NVIDIA App 开启 RTX Video HDR + Windows HDR 开启 + RTX GPU。

local LABEL = "rtx-hdr"

local function is_active()
    local vf = mp.get_property_native("vf") or {}
    for _, f in ipairs(vf) do
        if f.label == LABEL then return true end
    end
    return false
end

local function enable()
    if is_active() then return end
    -- vf-pre 不是可读写属性，必须用 vf 命令的 pre 子命令
    mp.command("vf pre @" .. LABEL .. ":d3d11vpp=nvidia-true-hdr")
    mp.set_property("target-colorspace-hint", "auto")
    mp.set_property("inverse-tone-mapping", "no")
end

local function disable()
    mp.command("vf remove @" .. LABEL)
end

local function toggle()
    if is_active() then
        disable()
        mp.osd_message("RTX Video HDR 已关闭", 2)
    else
        enable()
        mp.osd_message("RTX Video HDR 已启用", 2)
    end
end

-- 补帧/超分菜单用 vf set 会清空主列表；RTX HDR 用 vf pre 加在最前面不受影响。
-- 但如果 vf 主列表被清空后，vf pre 的滤镜仍然保留（mpv 的 vf set 只操作主列表）。

mp.register_script_message("rtx-hdr-toggle", toggle)

-- 切换文件后 [SDR] profile 会重置 target-colorspace-hint=no，需重新应用
mp.register_event("file-loaded", function()
    if is_active() then
        mp.set_property("target-colorspace-hint", "auto")
        mp.set_property("inverse-tone-mapping", "no")
    end
end)