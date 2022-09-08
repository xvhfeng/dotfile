local xlog = {
    _version = "xlog 0.1.0"
}

local opt = require "util.opt"
--local tbl = require "util.tbl"

xlog.usecolor = true
xlog.outpath = nil
xlog.level = "trace"
xlog.fp = nil
xlog.outpath_default = "~/.cache/nvim/xlog"
xlog.filepath = nil

xlog.ConsoleAndFile = 0
xlog.OnlyConsole = 1
xlog.OnlyFile = 2
-- if you want to close xlog in the nvim
-- please set xlog.noup = true between [require "xlog"] and xlog.setup() in init.lua
xlog.noup = false

--[===[
  log output:
  0 : output to console and file,if outfile is nil,output to console only and not throw error 
  1 : only output to console
  2 : only output to outfile,you must set outfile
--]===]
xlog.output = 0

xlog.setup = function(level, output, outpath)
    if xlog.noup then
        return
    end

    xlog.level = level
    xlog.output = output

    if xlog.OnlyFile == xlog.output or xlog.ConsoleAndFile == xlog.output then
       
        if opt.isNilOrEmpty(outpath) then
            xlog.outpath = outpath_default
        else
            xlog.outpath = outpath
        end

        if not opt.file_exists(xlog.outpath) then
            local cmd = string.format("mkdir -p %s",xlog.outpath)
            os.execute(cmd)
        end
    end

    xlog.filepath = string.format("%s/nvim-%s.log", xlog.outpath, opt.current_datatime_nosp())
    -- print(xlog.filepath)
    xlog.fp = io.open(xlog.filepath, "a+");
end

xlog.shutdown = function()
    xlog.fp:close()
    xlog.fp = nil
    xlog.filepath = nil
end

local modes = {{
    name = "trace",
    color = "\27[34m"
}, {
    name = "debug",
    color = "\27[36m"
}, {
    name = "info",
    color = "\27[32m"
}, {
    name = "warn",
    color = "\27[33m"
}, {
    name = "error",
    color = "\27[31m"
}, {
    name = "fatal",
    color = "\27[35m"
}}

local levels = {}
for i, v in ipairs(modes) do
    levels[v.name] = i
end

local round = function(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring

local tostring = function(...)
    local t = {}
    for i = 1, select('#', ...) do
        local x = select(i, ...)
        if type(x) == "number" then
            x = round(x, .01)
        end
        t[#t + 1] = _tostring(x)
    end
    return table.concat(t, " ")
end

for i, x in ipairs(modes) do
    local nameupper = x.name:upper()
    xlog[x.name] = function(fmt,...)

        if xlog.noup then
            return
        end

        -- Return early if we're below the log level
        if i < levels[xlog.level] then
            return
        end

        local msg = string.format(fmt,...)
        local info = debug.getinfo(2, "Sl")
       -- local sinfo = DataDumper(info,"debuginfo")
       -- print(sinfo)
        local lineinfo = info.short_src .. ":"  .. info.currentline  --  .. "@" .. info.name

        -- Output to console
        if xlog.OnlyConsole == xlog.output or xlog.ConsoleAndFile == xlog.output then
            print(string.format("%s %s %s %s %s \n\t-->> %s", 
                                xlog.usecolor and x.color or "", 
                                nameupper, opt.current_datatime_zhcn(), 
                                xlog.usecolor and "\27[0m" or "", lineinfo, msg))
        end

        -- Output to log file
        if xlog.OnlyFile == xlog.output or (xlog.ConsoleAndFile == xlog.output and xlog.outpath) then
            local str = string.format("%s %s %s \n\t-->> %s\n", 
                                    nameupper, 
                                    opt.current_datatime_zhcn(), 
                                    lineinfo, msg)
            if xlog.fp then 
                xlog.fp:write(str)
            end
        end
    end
end

xlog["blankline"] = function()
    if xlog.noup then
        return
    end

    -- Output to console
    if xlog.OnlyConsole == xlog.output or xlog.ConsoleAndFile == xlog.output then
        print("\n")
    end

    -- Output to log file
    if xlog.OnlyFile == xlog.output or (xlog.ConsoleAndFile == xlog.output and xlog.outpath) then
        if xlog.fp then 
            xlog.fp:write("\n")
        end
    end
end

return xlog
