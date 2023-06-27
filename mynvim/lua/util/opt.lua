local M = {}

M.tbl_haskey= function(tbl,key) 
    if tbl == nil then
        return false
    end
    for k, v in pairs(tbl) do
        if k == key then
            return true
        end
    end
    return false
end

M.tbl_hasval= function(tbl,val)
    if tbl == nil then
        return false
    end

    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

M.isNilOrEmptyTbl = function(tbl)
    return nil == tbl or nil == next(tbl)
end

M.isNotNilAndEmptyTbl = function(tbl)
    return nil ~= tbl and nil ~= next(tbl)
end
M.current_datatime_string = function(fmt)
    return os.date(fmt) 
end

M.current_datatime_zhcn = function()
    return os.date("%Y-%m-%d %H:%M:%S") 
end

M.current_datatime_nosp = function()
    return os.date("%Y%m%d-%H%M%S") 
end

M.isNilOrEmpty = function(s)
    return nil == s or "" == M.trim(s)
end

M.ltrim = function(s)
    return s:gsub("^%s+", "")
end

M.rtrim = function(s)
    return s:gsub("%s+$", "")
end

M.trim = function(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

M.file_exists = function(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

M.isRealFalse = function(v)
    return nil ~= v and false == v
end

M.isRealTrue = function(v)
    return nil ~= v and true == v
end

M.deepcopy = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function M.__FILE__() return debug.getinfo(2,'S').source end
function M.__LINE__() return debug.getinfo(2, 'l').currentline end

M.cword = function()
    return vim.fn.expand('<cword>')
end

M.isInArray = function(tbl,val)
    if "table" ~= type(tbl) then
        return false
    end

    for k,v in ipairs(tbl) do
        if v == val then
            return true;
        end
    end
    return false;
end

--[[
m.tbl_trace = function(name,tbl)
    if not xlog.Startup then
        return
    end

    local map = DataDumper(tbl,name)
    xlog.trace(map)
end
   --]]
return M
