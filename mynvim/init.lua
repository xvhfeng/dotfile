vim.loader.enable() 
if vim.fn.has('mac') == 1 then
    vim.g.HOME_PATH = "/Users/" .. vim.fn.expand('$USER')
    vim.cmd([[
        let g:python_host_prog = '/usr/bin/python'
        let g:python3_host_prog = '/opt/local/bin/python3'
        ]])
elseif vim.fn.has('unix') == 1 then
    vim.cmd([[
        let g:python_host_prog = '/usr/bin/python'
        let g:python3_host_prog = '/usr/bin/python3'
        ]])
    local username = vim.fn.system('whoami')
    if string.find(username, "root") then
        vim.g.HOME_PATH = "/root"
    else
        vim.g.HOME_PATH = "/home/" .. vim.fn.expand("$USER")
    end
else
    print("configure is only for mac or linux or WSL !")
    vim.g.HOME_PATH = " "
    return
end

local xlog = require("util.xlog")
xlog.Startup = false
if xlog.Startup then
    xlog.setup("trace", xlog.OnlyFile, "/tmp/nvim/xlog")
    xlog.trace("NVim Startup...")
end

vim.g.CONFIG = vim.g.HOME_PATH .. "/.config/nvim"
local repspath = vim.g.CONFIG .. "/reps"
vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.g.CONFIG
vim.g.REPSPATH = repspath

local lazypath = repspath .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)
require("core")
