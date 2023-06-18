local plugin = {}

plugin.core = {
    'kkvh/vim-docker-tools',
    config = function()
    end
}
plugin.mapping = {
    keys = { {
        mode = "n",
        key = {"<leader>", "c", "o"},
        action = '<cmd>DockerToolsToggle<CR>',
        short_desc = "Open DockerTools Mgr",
    },{
        mode = "n",
        key = {"<leader>", "c", "t"},
        action = '<cmd>ContainerStop<CR>',
        short_desc = "Stop DockerImage",
    },{
        mode = "n",
        key = {"<leader>", "c", "l"},
        action = '<cmd>ContainerLog<CR>',
        short_desc = "Show DockerImage Log",
    },{
        mode = "n",
        key = {"<leader>", "c", "D"},
        action = '<cmd>ContainerRemove<CR>',
        short_desc = "Remove DockerImage",
    },{
        mode = "n",
        key = {"<leader>", "c", "m"},
        action = '<cmd>ContainerRestart<CR>',
        short_desc = "Restart DockerImage",
    },{
        mode = "n",
        key = {"<leader>", "c", "p"},
        action = '<cmd>ContainerPause<CR>',
        short_desc = "Puase DockerImage",
    },{
        mode = "n",
        key = {"<leader>", "c", "s"},
        action = '<cmd>ContainerStart<CR>',
        short_desc = "Start DockerImage",
    }
    }
}

return plugin
