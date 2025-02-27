vim.loader.enable()
-- vim的宏很少用，并且经常q按错，首先就禁了再说
vim.cmd [[
nnoremap q <Nop>
]]

-- disable netrw at the very start of your init.lua
-- netrw 有很多的BUG，提前禁用
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

if vim.fn.has('mac') == 1 then
    vim.g.HOME_PATH = "/Users/" .. vim.fn.expand('$USER')
    vim.cmd([[
    let g:python_host_prog = '/usr/bin/python'
    let g:python3_host_prog = '/opt/homebrew/bin/python3'
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

local user_setting = {
    python3_host_prog =  'python3', -- add to your own python3 path
    snips_author = 'Bgm',
    snips_email = 'bgm.spk.xu@gmail.com',
    snips_github = 'https://github.com/xvhfeng',
}

for key, value in pairs(user_setting) do
    vim.g[key] = value
end

local xlog = require("util.xlog")
xlog.Startup = true
if xlog.Startup then
    xlog.setup("trace", xlog.OnlyFile, "/tmp/nvim/xlog")
    xlog.trace("NVim Startup...")
end

vim.g.CONFIG = vim.g.HOME_PATH .. "/.config/nvim"
local repspath = vim.g.CONFIG .. "/reps"
vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.g.CONFIG
vim.g.REPSPATH = repspath
vim.opt.path:append(vim.fn.stdpath("data") .. "/mason/bin")
vim.opt.runtimepath:append(repspath .. "/nvim-treesitter/parser")

local lazypath = repspath .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",  "--branch=main", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)
require("core")
