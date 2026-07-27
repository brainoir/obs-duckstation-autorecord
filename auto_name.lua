obs = obslua
local ffi = require("ffi")

ffi.cdef[[
    typedef void* HWND;
    typedef void* HANDLE;
    typedef unsigned long DWORD;
    typedef int BOOL;

    HWND GetDesktopWindow();
    HWND GetWindow(HWND hWnd, unsigned int uCmd);
    BOOL IsWindowVisible(HWND hWnd);
    int GetWindowTextA(HWND hWnd, char* lpString, int nMaxCount);
    DWORD GetWindowThreadProcessId(HWND hWnd, DWORD* lpdwProcessId);
    HANDLE OpenProcess(DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId);
    BOOL QueryFullProcessImageNameA(HANDLE hProcess, DWORD dwFlags, char* lpExeName, DWORD* lpdwSize);
    BOOL CloseHandle(HANDLE hObject);
]]

-- Чистим заголовок окна от системной шелухи
local function clean_title(raw_title)
    if not raw_title or raw_title == "" then return "" end
    local t = raw_title
    
    -- Игнорируем служебные фоновые окна Windows
    local lower = t:lower()
    if lower:find("msctfime") or lower:find("ime") or lower:find("default") then
        return ""
    end

    -- Вырезаем слово DuckStation и версию
    t = t:gsub("[Dd]uck[Ss]tation[%w%s%.%-_]*", "")
    -- Вырезаем ID диска [SLUS-00404] или (SLES-12345)
    t = t:gsub("%s*%[.-%]", ""):gsub("%s*%(.-%)", "")
    -- Убираем лишние символы разделителей
    t = t:gsub("^[%s%-%|%:]+", ""):gsub("[%s%-%|%:]+$", "")
    -- Убираем недопустимые символы для имен файлов Windows
    t = t:gsub('[%/%:%*%?%"%<%>%|\\]', ""):match("^%s*(.-)%s*$")
    
    return t or ""
end

-- Ищем окно DuckStation, содержащее НАСТОЯЩЕЕ название игры
local function get_real_game_title()
    local buf = ffi.new("char[512]")
    local exe_buf = ffi.new("char[260]")
    local pid_buf = ffi.new("DWORD[1]")
    local size_buf = ffi.new("DWORD[1]")
    
    local GW_CHILD = 5
    local GW_HWNDNEXT = 2
    
    local hwnd = ffi.C.GetWindow(ffi.C.GetDesktopWindow(), GW_CHILD)
    while hwnd ~= nil do
        if ffi.C.IsWindowVisible(hwnd) then
            ffi.C.GetWindowThreadProcessId(hwnd, pid_buf)
            local pid = pid_buf[0]
            if pid > 0 then
                local hProc = ffi.C.OpenProcess(0x1000, 0, pid)
                if hProc ~= nil then
                    size_buf[0] = 260
                    if ffi.C.QueryFullProcessImageNameA(hProc, 0, exe_buf, size_buf) ~= 0 then
                        local exe_path = ffi.string(exe_buf, size_buf[0]):lower()
                        if exe_path:find("duckstation") then
                            local len = ffi.C.GetWindowTextA(hwnd, buf, 512)
                            if len > 0 then
                                local raw_title = ffi.string(buf, len)
                                local cleaned = clean_title(raw_title)
                                -- Если после очистки мы получили РЕАЛЬНОЕ название игры
                                if cleaned ~= "" then
                                    ffi.C.CloseHandle(hProc)
                                    return cleaned
                                end
                            end
                        end
                    end
                    ffi.C.CloseHandle(hProc)
                end
            end
        end
        hwnd = ffi.C.GetWindow(hwnd, GW_HWNDNEXT)
    end
    return "DuckStation"
end

function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_RECORDING_STARTING then
        local game_name = get_real_game_title()
        
        local config = obs.obs_frontend_get_profile_config()
        if config ~= nil then
            local new_format = game_name .. " - %CCYY-%MM-%DD_%hh-%mm-%ss"
            obs.config_set_string(config, "Output", "FilenameFormatting", new_format)
        end
    end
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(on_event)
end