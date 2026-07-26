obs = obslua
local ffi = require("ffi")

ffi.cdef[[
    typedef void* HWND;
    typedef void* HANDLE;
    typedef unsigned long DWORD;
    typedef int BOOL;
    typedef unsigned short WCHAR;

    HWND GetDesktopWindow();
    HWND GetWindow(HWND hWnd, unsigned int uCmd);
    BOOL IsWindowVisible(HWND hWnd);
    int GetWindowTextW(HWND hWnd, WCHAR* lpString, int nMaxCount);
    DWORD GetWindowThreadProcessId(HWND hWnd, DWORD* lpdwProcessId);
    HANDLE OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId);
    BOOL QueryFullProcessImageNameA(HANDLE hProcess, DWORD dwFlags, char* lpExeName, DWORD* lpdwSize);
    BOOL CloseHandle(HANDLE hObject);

    int WideCharToMultiByte(
        unsigned int CodePage,
        DWORD dwFlags,
        const WCHAR* lpWideCharStr,
        int cchWideChar,
        char* lpMultiByteStr,
        int cbMultiByte,
        const char* lpDefaultChar,
        BOOL* lpUsedDefaultChar
    );
]]

local wbuf = ffi.new("WCHAR[512]")
local utf8_buf = ffi.new("char[1024]")
local exe_buf = ffi.new("char[260]")
local pid_buf = ffi.new("DWORD[1]")
local size_buf = ffi.new("DWORD[1]")

local is_auto_recording = false
local cooldown = 0
local POLL_INTERVAL = 300
local CP_UTF8 = 65001

-- Reads the window title in UTF-16 and safely converts it to UTF-8 to prevent encoding crashes
local function get_utf8_window_text(hwnd)
    local len = ffi.C.GetWindowTextW(hwnd, wbuf, 512)
    if len <= 0 then return "" end
    
    local utf8_len = ffi.C.WideCharToMultiByte(CP_UTF8, 0, wbuf, len, utf8_buf, 1024, nil, nil)
    if utf8_len <= 0 then return "" end
    
    return ffi.string(utf8_buf, utf8_len)
end

local function get_game_title(raw_title)
    if not raw_title or raw_title == "" then return nil end
    local lower = raw_title:lower()

    -- 1. Ignore background Qt and OS service windows
    if lower:find("msctfime") or
       lower:find("default ime") or
       lower:find("ime") or
       lower:find("_q_titlebar") or
       lower:find("temp window") or
       lower:find("duckstation") then
        return nil
    end

    -- 2. Ignore state-restore prompts and modal settings dialogs
    if lower:find("загрузить") or
       lower:find("состояние") or
       lower:find("возобновл") or
       lower:find("сохранение") or
       lower:find("настройки") or
       lower:find("settings") or
       lower:find("confirm") or
       lower:find("dialog") or
       lower:find("resume") or
       lower:find("restore") then
        return nil
    end

    -- Strip disc ID tags (e.g. [SLUS-00404]) and invalid file path characters
    local t = raw_title:gsub("[%[%(]%w+%-%d+[%]%)]", "")
    t = t:gsub('[%/%:%*%?%"%<%>%|\\]', ""):match("^%s*(.-)%s*$")

    if t and t ~= "" then
        return t
    end
    return nil
end

local function find_active_game()
    local GW_CHILD = 5
    local GW_HWNDNEXT = 2
    local GW_OWNER = 4

    local hwnd = ffi.C.GetWindow(ffi.C.GetDesktopWindow(), GW_CHILD)
    while hwnd ~= nil do
        if ffi.C.IsWindowVisible(hwnd) then
            -- Verify window is a top-level window without an owner (excludes popup modal dialogs)
            local owner = ffi.C.GetWindow(hwnd, GW_OWNER)
            if owner == nil or ffi.cast("uintptr_t", owner) == 0 then
                ffi.C.GetWindowThreadProcessId(hwnd, pid_buf)
                local pid = pid_buf[0]
                if pid > 0 then
                    local hProc = ffi.C.OpenProcess(0x1000, 0, pid)
                    if hProc ~= nil then
                        size_buf[0] = 260
                        if ffi.C.QueryFullProcessImageNameA(hProc, 0, exe_buf, size_buf) ~= 0 then
                            local exe_path = ffi.string(exe_buf, size_buf[0]):lower()
                            if exe_path:find("duckstation") then
                                local raw_title = get_utf8_window_text(hwnd)
                                local game_name = get_game_title(raw_title)
                                if game_name then
                                    ffi.C.CloseHandle(hProc)
                                    return game_name
                                end
                            end
                        end
                        ffi.C.CloseHandle(hProc)
                    end
                end
            end
        end
        hwnd = ffi.C.GetWindow(hwnd, GW_HWNDNEXT)
    end
    return nil
end

local function timer_callback()
    if cooldown > 0 then
        cooldown = cooldown - 1
        return
    end

    local game_name = find_active_game()
    local active = obs.obs_frontend_recording_active()

    -- Game is running and recording is inactive -> Apply name prefix and start recording
    if game_name and not active then
        local config = obs.obs_frontend_get_profile_config()
        if config ~= nil then
            local new_format = game_name .. " - %CCYY-%MM-%DD_%hh-%mm-%ss"
            obs.config_set_string(config, "Output", "FilenameFormatting", new_format)
        end
        obs.obs_frontend_recording_start()
        is_auto_recording = true
        cooldown = 3

    -- Game closed and auto-recording was active -> Stop recording safely
    elseif not game_name and active and is_auto_recording then
        obs.obs_frontend_recording_stop()
        is_auto_recording = false
        cooldown = 5
    end
end

function script_description()
    return "<h2>DuckStation Auto-Recorder & Dynamic Namer</h2>" ..
           "<p>Automates OBS recording for DuckStation with a seamless workflow tailored for zero-re-encode editing in <b>LosslessCut</b>.</p>" ..
           "<p><b>Workflow Philosophy:</b></p>" ..
           "<ul>" ..
           "<li>Designed for low-end PCs and quick content creation without heavy video editors or rendering.</li>" ..
           "<li>Play, exit instantly via <b>Alt+F4</b>, and resume later from save-states.</li>" ..
           "<li>Produces clean, isolated clip segments prefixed by the game title.</li>" ..
           "<li>Allows instant sorting in File Explorer by name/date to batch-merge takes or delete bad runs in seconds.</li>" ..
           "</ul>" ..
           "<p><b>Key Features:</b></p>" ..
           "<ul>" ..
           "<li><b>Auto Start/Stop:</b> Starts instantly when the game loads, stops cleanly on Alt+F4 or menu exit.</li>" ..
           "<li><b>Dynamic Naming:</b> Prefixes output filenames with clean game titles (strips disc IDs and system tags).</li>" ..
           "<li><b>Smart Filtering:</b> Ignores launcher UI, save-state prompts, and Qt background windows to prevent false starts.</li>" ..
           "<li><b>Crash Protection:</b> Uses Win32 Unicode (UTF-8) conversion to prevent obs-websocket encoding crashes.</li>" ..
           "</ul>"
end

function script_load(settings)
    obs.timer_add(timer_callback, POLL_INTERVAL)
end

function script_unload()
    obs.timer_remove(timer_callback)
end