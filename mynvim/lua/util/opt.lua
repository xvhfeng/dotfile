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

return M