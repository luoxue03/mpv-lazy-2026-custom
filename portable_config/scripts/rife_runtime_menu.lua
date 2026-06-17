local mp = require 'mp'
local utils = require 'mp.utils'
local options = require 'mp.options'

local script_name = mp.get_script_name()
local current_config_path = mp.command_native({ 'expand-path', '~~/script-opts/rife_runtime.json' })
local default_config_path = mp.command_native({ 'expand-path', '~~/script-opts/rife_runtime_default.json' })
local runtime_vpy = '~~/vs/MEMC_RIFE_NV_runtime.vpy'
local opts = { danmaku_fps = '60/1.001' }
options.read_options(opts, 'uosc_danmaku', function() end)

local models = {
    { id = 46, label = '4.6', hint = '稳定通用', flow_scale = true, ensemble = true, v2 = true },
    { id = 4151, label = '4.15 lite', hint = '轻量旧模型;性能优先', flow_scale = false, ensemble = true, v2 = true },
    { id = 422, label = '4.22', hint = '旧质量取向;负载较高', flow_scale = false, ensemble = false, v2 = true },
    { id = 4221, label = '4.22 lite', hint = '旧轻量模型;速度优先', flow_scale = false, ensemble = false, v2 = true },
    { id = 4251, label = '4.25 lite', hint = '轻量模型', flow_scale = false, ensemble = false, v2 = true },
    { id = 426, label = '4.26', hint = '较新质量取向;负载高', flow_scale = false, ensemble = false, v2 = true },
    { id = 4262, label = '4.26 heavy', hint = '重型模型;负载极高', flow_scale = false, ensemble = false, v2 = true },
    { id = 47, label = '4.7', hint = '侧重横移/细线稳定性', flow_scale = false, ensemble = false, v2 = false },
    { id = 48, label = '4.8', hint = '动画线条/色块场景', flow_scale = false, ensemble = false, v2 = false },
    { id = 49, label = '4.9', hint = '动画/实拍混合场景', flow_scale = false, ensemble = false, v2 = false },
}

local turbo_options = {
    { value = 0, label = '0', hint = '质量优先路径;支持 ensemble 的模型负载最高' },
    { value = 1, label = '1', hint = 'TensorRT 外部处理路径;质量/兼容均衡，负载较高' },
    { value = 2, label = '2', hint = '快速路径;优先流畅，适合 4K 播放' },
}

local flow_options = {
    { value = 1.0, label = '1.0', hint = '完整光流分辨率;画质⬆⬆⬆，负载⬆⬆⬆' },
    { value = 0.5, label = '0.5', hint = '半分辨率光流;画质⬆⬆，负载⬆⬆' },
    { value = 0.25, label = '0.25', hint = '四分之一光流;画质⬆，负载⬆' },
}

local h_pre_options = {
    { value = 2160, label = '2160', ratio = '100%', hint = '原始4K高度;画质⬆⬆⬆负载⬆⬆⬆' },
    { value = 1920, label = '1920', ratio = '约79%', hint = '4K高度降低;画质⬆⬆⬆负载⬆⬆' },
    { value = 1608, label = '1608', ratio = '约55%', hint = '宽银幕4K高度;画质⬆⬆负载⬆' },
    { value = 1440, label = '1440', ratio = '约44%', hint = '2K处理高度;画质⬆负载⬆' },
}

local fallback_config = {
    model = 46,
    model_label = '4.6',
    turbo = 2,
    flow_scale = 1.0,
    h_pre = 2160,
    fps_num = 2,
    fps_den = 1,
    sc_mode = 1,
    gpu = 0,
    gpu_t = 2,
    ws_size = 0,
    lk_fmt = false,
}

local function model_by_id(id)
    id = tonumber(id)
    for _, model in ipairs(models) do
        if model.id == id then return model end
    end
    return models[1]
end

local function normalize_config(config)
    if type(config) ~= 'table' then config = {} end
    local model = model_by_id(config.model or fallback_config.model)
    local turbo = tonumber(config.turbo or fallback_config.turbo) or fallback_config.turbo
    if turbo ~= 0 and turbo ~= 1 and turbo ~= 2 then turbo = fallback_config.turbo end
    local flow_scale = tonumber(config.flow_scale or fallback_config.flow_scale) or fallback_config.flow_scale
    if flow_scale ~= 1.0 and flow_scale ~= 0.5 and flow_scale ~= 0.25 then flow_scale = fallback_config.flow_scale end
    if not model.flow_scale and flow_scale ~= 1.0 then flow_scale = 1.0 end
    local h_pre = tonumber(config.h_pre or fallback_config.h_pre) or fallback_config.h_pre
    if h_pre ~= 2160 and h_pre ~= 1920 and h_pre ~= 1608 and h_pre ~= 1440 then h_pre = fallback_config.h_pre end

    return {
        model = model.id,
        model_label = model.label,
        turbo = turbo,
        flow_scale = flow_scale,
        h_pre = h_pre,
        fps_num = tonumber(config.fps_num or fallback_config.fps_num) or fallback_config.fps_num,
        fps_den = tonumber(config.fps_den or fallback_config.fps_den) or fallback_config.fps_den,
        sc_mode = tonumber(config.sc_mode or fallback_config.sc_mode) or fallback_config.sc_mode,
        gpu = tonumber(config.gpu or fallback_config.gpu) or fallback_config.gpu,
        gpu_t = tonumber(config.gpu_t or fallback_config.gpu_t) or fallback_config.gpu_t,
        ws_size = tonumber(config.ws_size or fallback_config.ws_size) or fallback_config.ws_size,
        lk_fmt = config.lk_fmt == true,
    }
end

local function read_json(path)
    local file = io.open(path, 'r')
    if not file then return nil end
    local content = file:read('*all')
    file:close()
    local ok, data = pcall(utils.parse_json, content)
    if not ok or type(data) ~= 'table' then return nil end
    return data
end

local function read_config(path)
    return normalize_config(read_json(path))
end

local function write_config(path, config)
    config = normalize_config(config)
    config.updated_by = script_name
    config.updated_at = os.date('%Y-%m-%d %H:%M:%S')
    local file = io.open(path, 'w')
    if not file then
        mp.osd_message('RIFE 自定义参数：无法写入配置', 4)
        return false
    end
    file:write(utils.format_json(config))
    file:close()
    return true
end

local function describe(config)
    return string.format('RIFE %s｜turbo=%d｜flow_scale=%.2g｜H=%d', config.model_label, config.turbo, config.flow_scale, config.h_pre)
end

local function describe_short(config)
    return string.format('%s / T%d / F%.2g / H%d', config.model_label, config.turbo, config.flow_scale, config.h_pre)
end

local function h_pre_option_by_value(value)
    value = tonumber(value)
    for _, option in ipairs(h_pre_options) do
        if option.value == value then return option end
    end
    return h_pre_options[1]
end

local function h_pre_summary(value)
    local option = h_pre_option_by_value(value)
    return string.format('H_Pre=%d(%s)', option.value, option.ratio)
end

local function h_pre_explain(value)
    local option = h_pre_option_by_value(value)
    return string.format('%s：%s', h_pre_summary(option.value), option.hint)
end

local function filter_state(label, name)
    local filters = mp.get_property_native('vf') or {}
    for _, filter in ipairs(filters) do
        local params = filter.params or {}
        if filter.label == label or filter.name == name or params[name] ~= nil then
            return true
        end
    end
    return false
end

local function apply_config(config)
    config = normalize_config(config)
    if not write_config(current_config_path, config) then return end

    local had_danmaku_fps = filter_state('danmaku', 'fps')
    mp.commandv('vf', 'remove', '@rife_runtime')
    if had_danmaku_fps then
        mp.commandv('vf', 'remove', '@danmaku')
    end

    mp.add_timeout(0.05, function()
        mp.commandv('vf', 'append', '@rife_runtime:vapoursynth=' .. runtime_vpy)
        if had_danmaku_fps then
            mp.add_timeout(0.05, function()
                mp.commandv('vf', 'append', '@danmaku:fps=fps=' .. opts.danmaku_fps)
            end)
        end
    end)
    mp.osd_message('已应用：' .. describe(config), 4)
end
local function apply_default()
    apply_config(read_config(default_config_path))
end

local function save_default()
    local config = read_config(current_config_path)
    if write_config(default_config_path, config) then
        mp.osd_message('已设为默认：' .. describe(config), 4)
    end
end

local function select_config(model_id, turbo_value, flow_value)
    local config = read_config(current_config_path)
    config.model = tonumber(model_id)
    config.turbo = tonumber(turbo_value)
    config.flow_scale = tonumber(flow_value)
    apply_config(config)
end

local function set_h_pre(h_pre_value, model_id, turbo_value, flow_value)
    local config = read_config(current_config_path)
    config.h_pre = tonumber(h_pre_value)
    if model_id then config.model = tonumber(model_id) end
    if turbo_value then config.turbo = tonumber(turbo_value) end
    if flow_value then config.flow_scale = tonumber(flow_value) end
    apply_config(config)
end

local function h_pre_item(option, current, model, turbo, flow)
    local value = { 'script-message-to', script_name, 'set-h-pre', tostring(option.value) }
    local active = current.h_pre == option.value
    if model then
        value = { 'script-message-to', script_name, 'set-h-pre', tostring(option.value), tostring(model.id), tostring(turbo.value), tostring(flow.value) }
        active = active and current.model == model.id and current.turbo == turbo.value and current.flow_scale == flow.value
    end
    return {
        title = 'H_Pre=' .. option.label,
        hint = option.hint .. ';处理像素量 ' .. option.ratio,
        active = active,
        value = value,
    }
end

local function flow_item(model, turbo, flow, current)
    local h_pre_items = {}
    for _, option in ipairs(h_pre_options) do
        h_pre_items[#h_pre_items + 1] = h_pre_item(option, current, model, turbo, flow)
    end
    return {
        title = 'flow_scale=' .. flow.label,
        hint = flow.hint,
        active = current.model == model.id and current.turbo == turbo.value and current.flow_scale == flow.value,
        items = h_pre_items,
    }
end

local function turbo_hint(model, turbo)
    local hint = turbo.hint
    if turbo.value == 0 and not model.ensemble then
        hint = hint .. ''
    end
    if turbo.value == 2 and not model.v2 then
        hint = hint .. ''
    end
    return hint
end

local function turbo_item(model, turbo, current)
    local hint = turbo_hint(model, turbo)
    local allow_flow_scale = model.flow_scale and turbo.value == 1
    if not allow_flow_scale then
        local h_pre_items = {}
        local flow = { value = 1.0 }
        for _, option in ipairs(h_pre_options) do
            h_pre_items[#h_pre_items + 1] = h_pre_item(option, current, model, turbo, flow)
        end
        return {
            title = 'Turbo ' .. turbo.label,
            hint = hint .. ';flow_scale为1.0;',
            active = current.model == model.id and current.turbo == turbo.value and current.flow_scale == 1.0,
            items = h_pre_items,
        }
    end

    local items = {}
    for _, flow in ipairs(flow_options) do
        items[#items + 1] = flow_item(model, turbo, flow, current)
    end
    return {
        title = 'Turbo ' .. turbo.label,
        hint = hint,
        items = items,
    }
end

local function model_item(model, current)
    local items = {}
    for _, turbo in ipairs(turbo_options) do
        items[#items + 1] = turbo_item(model, turbo, current)
    end
    return {
        title = model.label,
        hint = model.hint ,
        active = current.model == model.id,
        items = items,
    }
end

local function open_menu()
    local current = read_config(current_config_path)
    local default = read_config(default_config_path)
    local model_items = {}
    for _, model in ipairs(models) do
        model_items[#model_items + 1] = model_item(model, current)
    end
    local h_pre_items = {}
    for _, option in ipairs(h_pre_options) do
        h_pre_items[#h_pre_items + 1] = h_pre_item(option, current)
    end

    local menu = {
        type = 'rife-runtime-menu',
        title = 'RIFE 自定义参数',
        search_style = 'disabled',
        search_submenus = true,
        items = {
            {
                title = '设置当前配置为默认',
                hint = describe_short(current),
                value = { 'script-message-to', script_name, 'save-default' },
            },
            {
                title = '应用默认配置',
                hint = describe_short(default) .. '｜Ctrl+Alt+f',
                value = { 'script-message-to', script_name, 'apply-default' },
            },
            {
                title = '选择模型',
                hint = '选模型 / Turbo / flow_scale / H_Pre处理高度',
                items = model_items,
            },
            {
                title = '选择全局处理高度',
                hint = h_pre_explain(current.h_pre) .. ';模型下也可单独选择',
                items = h_pre_items,
            },
        },
    }

    mp.commandv('script-message-to', 'uosc', 'open-menu', utils.format_json(menu))
end

mp.register_script_message('open-menu', open_menu)
mp.register_script_message('apply-default', apply_default)
mp.register_script_message('save-default', save_default)
mp.register_script_message('select', select_config)
mp.register_script_message('set-h-pre', set_h_pre)
mp.add_key_binding(nil, 'open-menu', open_menu)
mp.add_key_binding(nil, 'apply-default', apply_default)
mp.add_forced_key_binding('Ctrl+Alt+f', 'apply-default-shortcut', apply_default)
