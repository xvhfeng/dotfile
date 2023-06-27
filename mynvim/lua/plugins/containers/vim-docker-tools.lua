local plugin = {}

plugin.core = {'kkvh/vim-docker-tools', config = function() end}
plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>cd", name = "Docker"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>cdt",
                    action = '<cmd>DockerToolsToggle<CR>',
                    desc = "Open DockerTools",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cds",
                    action = '<cmd>ContainerStop<CR>',
                    desc = "Stop DockerImage",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cdl",
                    action = '<cmd>ContainerLog<CR>',
                    desc = "Show DockerImage Log",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cdd",
                    action = '<cmd>ContainerRemove<CR>',
                    desc = "Remove DockerImage",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cdr",
                    action = '<cmd>ContainerRestart<CR>',
                    desc = "Restart DockerImage",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cdp",
                    action = '<cmd>ContainerPause<CR>',
                    desc = "Puase DockerImage",
                    cond = {target = "l"}
                }, {
                    mode = "n",
                    key = "<leader>cdb",
                    action = '<cmd>ContainerStart<CR>',
                    desc = "Start DockerImage",
                    cond = {target = "l"}
                }
            }
        }
    }
}

return plugin
