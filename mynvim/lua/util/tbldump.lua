local M = {}

require "util.tbl"
local xlog = require("util.xlog")

M.tbl_trace = function(name,tbl,filename,lineno) 
    if not xlog.Startup then
        return
    end
    
    name = name or "TBLDUMP"

    if nil == tbl then
        return
    end

    local map = DataDumper(tbl,name)
    if nil ~= filename and nil ~= lineno then
        xlog.trace("trace tbl at -> " .. filename .. "[" .. lineno .. "]")
    end
    xlog.trace(map)
end

return M