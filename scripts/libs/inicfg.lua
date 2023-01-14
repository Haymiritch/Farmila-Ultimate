-- The ini file config library.
-- 
-- This file is part of SA MoonLoader package.
-- Licensed under the MIT License.
-- Copyright (c) 2019, BlastHack Team <blast.hk>

-- Adapted for RakSAMP Lite by Heroku <t.me/badherta>

local inicfg = {}
local ffi = require("ffi")

ffi.cdef[[
    int __stdcall CreateDirectoryA(const char* src, void* lpSecurityAttributes);
    int __stdcall GetLastError();
]]

local function doesDirectoryOrFileExist(name)
    local ok, err, code = os.rename(name, name)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

local function createDirectory(name)
    local ret = ffi.C.CreateDirectoryA(name, ffi.cast("void*", 0))
    if ret == 0 then
        local err = ffi.C.GetLastError()
        return nil, err
    end
    return true
end

local function find_config(file)
    local workdir = getPath()
    local paths = {
        workdir..[[\config\]]..file..'.ini',
        workdir..[[\config\]]..file,
        file,
    }
    for _, path in ipairs(paths) do
        if doesDirectoryOrFileExist(path) then
            return path
        end
    end
    return nil
end

local function ini_value(val)
    local lwr = val:lower()
    if lwr == 'true' then return true end
    if lwr == 'false' then return false end
    return tonumber(val) or val
end

function inicfg.load(default, file)
    local path = find_config(file)
    if not path then return default end
    local f = io.open(path, 'r')
    if not f then return nil end
    local data = default or {}
    local cursec
    for line in f:lines() do
        local secname = string.match(line, '^%s*%[([^%[%]]+)%]%s*$')
        if secname then
            local section = tonumber(secname) or secname
            if data[section] then
                cursec = data[section]
            else
                cursec = {}
                data[section] = cursec
            end
        else
            local key, value = line:match('^%s*([^=%s]+)%s-=%s-(.+)$')
            --local key, value = line:match('^%s*([^=%s]+)%s-=%s-(.-)$')
            if key and value then
                if not cursec then
                    error('parameter out of section')
                end
                cursec[ini_value(key)] = ini_value(value)
            end
        end
    end
    f:close()
    return data
end

function inicfg.save(data, file)
    local file = file
    local path = find_config(file)
    local dir
    if not path then
        if file:match('^%a:[\\/]') then
            dir = file:match('(.+[\\/]).-')
            path = file
        else
            if file:sub(-4):lower() ~= '.ini' then
                file = file..'.ini'
            end
            dir = getPath()..[[\config\]]
            path = dir..file
        end
    end
    if dir and not doesDirectoryOrFileExist(dir) then
        createDirectory(dir)
    end
    local f = io.open(path, 'w')
    if f then
        for secname, secdata in pairs(data) do
            assert(type(secdata) == 'table')
            f:write('['..tostring(secname)..']\n')
            for key, value in pairs(secdata) do
                f:write(tostring(key)..'='..tostring(value)..'\n')
            end
            f:write('\n')
        end
        f:close()
        return true
    end
    return false
end

return inicfg
