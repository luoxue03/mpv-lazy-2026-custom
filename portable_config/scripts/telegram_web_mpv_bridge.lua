local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'

local root_dir = mp.command_native({ 'normalize-path', mp.command_native({ 'expand-path', '~~/..' }) })
local bridge_dir = root_dir .. '/tools/telegram-web-mpv-bridge'
local python_path = bridge_dir .. '/.venv/Scripts/python.exe'
local bridge_path = bridge_dir .. '/bridge.py'
local mpv_path = root_dir .. '/mpv.exe'
local http_port = 8999
local ws_port = 9000

local function ps_quote(value)
    value = tostring(value or ''):gsub("'", "''")
    return "'" .. value .. "'"
end

local function exists(path)
    return utils.file_info(path) ~= nil
end

local function run_ps(script, callback)
    mp.command_native_async({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = { 'powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script },
    }, function(success, result)
        if callback then callback(success, result or {}) end
    end)
end

local function port_check_script(port)
    return table.concat({
        '$ok=$false',
        '$c=New-Object System.Net.Sockets.TcpClient',
        'try { $c.Connect(' .. ps_quote('127.0.0.1') .. ', ' .. tostring(port) .. '); $ok=$true } catch { $ok=$false } finally { $c.Close() }',
        'if ($ok) { Write-Output 1 } else { Write-Output 0 }',
    }, '; ')
end

local function is_running(callback)
    run_ps(port_check_script(http_port), function(success, result)
        local stdout = result.stdout or ''
        callback(success and stdout:match('1') ~= nil)
    end)
end

local function show_dependency_hint()
    mp.osd_message('Telegram Bridge：缺少本地 .venv，请先按 README 安装依赖', 6)
    msg.error('telegram bridge python not found: ' .. python_path)
end

local function start_bridge()
    if not exists(bridge_path) then
        mp.osd_message('Telegram Bridge：未找到 bridge.py', 5)
        msg.error('bridge.py not found: ' .. bridge_path)
        return
    end
    if not exists(python_path) then
        show_dependency_hint()
        return
    end

    local out_log = bridge_dir .. '/bridge.out.log'
    local err_log = bridge_dir .. '/bridge.err.log'
    local ps = table.concat({
        '$python=' .. ps_quote(python_path),
        '$bridge=' .. ps_quote(bridge_path),
        '$work=' .. ps_quote(bridge_dir),
        '$out=' .. ps_quote(out_log),
        '$err=' .. ps_quote(err_log),
        '$mpv=' .. ps_quote(mpv_path),
        'Start-Process -WindowStyle Hidden -FilePath $python -ArgumentList @($bridge, ' .. ps_quote('--http-port') .. ', ' .. ps_quote(tostring(http_port)) .. ', ' .. ps_quote('--ws-port') .. ', ' .. ps_quote(tostring(ws_port)) .. ', ' .. ps_quote('--mpv-path') .. ', $mpv) -WorkingDirectory $work -RedirectStandardOutput $out -RedirectStandardError $err',
        'Write-Output started',
    }, '; ')

    run_ps(ps, function(success, result)
        if success then
            mp.osd_message('Telegram Bridge：已启动', 3)
            mp.set_property_bool('user-data/telegram-web-mpv-bridge/running', true)
        else
            mp.osd_message('Telegram Bridge：启动失败', 5)
            msg.error(result.stderr or result.stdout or 'unknown start failure')
        end
    end)
end

local function stop_bridge()
    local pattern = '*telegram-web-mpv-bridge*bridge.py*'
    local ps = table.concat({
        '$procs = Get-CimInstance Win32_Process | Where-Object { ($_.Name -match ' .. ps_quote('^pythonw?[.]exe$') .. ') -and ($_.CommandLine -like ' .. ps_quote(pattern) .. ') }',
        '$count = @($procs).Count',
        '$procs | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }',
        'Write-Output $count',
    }, '; ')

    run_ps(ps, function(success, result)
        if success then
            local count = tonumber((result.stdout or ''):match('%d+')) or 0
            mp.osd_message(count > 0 and 'Telegram Bridge：已停止' or 'Telegram Bridge：未在运行', 3)
            mp.set_property_bool('user-data/telegram-web-mpv-bridge/running', false)
        else
            mp.osd_message('Telegram Bridge：停止失败', 5)
            msg.error(result.stderr or result.stdout or 'unknown stop failure')
        end
    end)
end

local function status_bridge()
    is_running(function(running)
        mp.set_property_bool('user-data/telegram-web-mpv-bridge/running', running)
        mp.osd_message(running and 'Telegram Bridge：运行中' or 'Telegram Bridge：未运行', 3)
    end)
end

local function toggle_bridge()
    is_running(function(running)
        if running then stop_bridge() else start_bridge() end
    end)
end

mp.register_script_message('start', start_bridge)
mp.register_script_message('stop', stop_bridge)
mp.register_script_message('status', status_bridge)
mp.register_script_message('toggle', toggle_bridge)

mp.add_key_binding(nil, 'toggle', toggle_bridge)
mp.add_key_binding(nil, 'status', status_bridge)

mp.add_timeout(1, status_bridge)
