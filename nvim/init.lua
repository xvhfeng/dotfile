if vim.fn.has('mac') == 1 then
    vim.g.HOME_PATH = "/Users/" .. vim.fn.expand('$USER')
    vim.cmd ([[
        let g:python_host_prog = '/usr/bin/python'
        let g:python3_host_prog = '/opt/local/bin/python3'
    ]])
elseif vim.fn.has('unix') == 1 then
    vim.g.HOME_PATH = "/home/" .. vim.fn.expand("$USER")
else
    print("configure is only for mac or linux or WSL !")
    vim.g.HOME_PATH = " "
    return
end

local xlog = require("util.xlog")
xlog.noup = true
if not xlog.noup  then 
    xlog.setup("trace",xlog.OnlyFile,vim.g.HOME_PATH.."/.cache/nvim/xlog")
    xlog.trace("NVim Startup...")
end

vim.g.CONFIG = vim.g.HOME_PATH .. "/.config/nvim"
vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.g.CONFIG

local execute = vim.api.nvim_command
local fn = vim.fn


local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'


if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '-b' , 'myself' , 'https://github.com/xvhfeng/packer.nvim.git', install_path })
    execute 'packadd packer.nvim'
end
packer_ok, packer = pcall(require, "packer")

if not packer_ok then
    print('can not load packer.')
    return
end

packer.init {
    ---[===[
    config = {
        max_jobs = nil,
        opt_default = false,
        git = {
            cmd = 'git',
            subcommands = {
                update = 'pull --ff-only --progress --rebase=false',
                install = 'clone --depth %i --no-single-branch --progress',
                fetch = 'fetch --depth 999999 --progress',
                checkout = 'checkout %s --',
                update_branch = 'merge --ff-only @{u}',
                current_branch = 'branch --show-current',
                diff = 'log --color=never --pretty=format:FMT --no-show-signature HEAD@{1}...HEAD',
                diff_fmt = '%%h %%s (%%cr)',
                get_rev = 'rev-parse --short HEAD',
                get_msg = 'log --color=never --pretty=format:FMT --no-show-signature HEAD -n 1',
                submodules = 'submodule update --init --recursive --progress'
            },
            depth = 1,
            clone_timeout = 60,
            default_url_format = 'https://github.com/%s'
        },
        display = {
            open_fn = require('packer.util').float,
          },
        
          --[===[
        display = {
            non_interactive = false,
            open_fn = nil,
            open_cmd = '65vnew \\[packer\\]',
            working_sym = '⟳',
            error_sym = '✗',
            done_sym = '✓',
            removed_sym = '-',
            moved_sym = '→',
            header_sym = '━',
            show_all_info = true,
            prompt_border = 'double',
            keybindings = {
                quit = 'q',
                toggle_info = '<CR>',
                diff = 'd',
                prompt_revert = 'r'
            }
        },
        --]===]
        luarocks = {python_cmd = 'python'},
        log = {level = 'warn'},
        profile = {enable = false, threshold = 1}
    }
    --]===]

    --[==[
    config = {
        max_jobs = 20,
    },
    git = {
        depth = 1, -- Git clone depth
        clone_timeout = 600, -- Timeout, in seconds, for git clones
        max_jobs=10,
        --default_url_format = 'https://github.com/%s' -- Lua format string used for "aaa/bbb" style plugins
    }
    --]==]
}

require("core")
