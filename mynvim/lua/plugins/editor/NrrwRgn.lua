local plugin = {}

plugin.core = {
    "chrisbra/NrrwRgn",
}


plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>en", name = "NarrowedWindow"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>enr",
                    action = '<cmd>NR<cr>',
                    desc = "Move SeleceRange To NarrWin",
                },
                {
                    mode = "n",
                    key = "<leader>enw",
                    action = '<cmd>NW<cr>',
                    desc = "Open Current VWin In New NarrWin",
                },
                {
                    mode = "n",
                    key = "<leader>enb",
                    action = '<cmd>WR<cr>',
                    desc = "Write Changed To OrgiBuffer",
                },
                {
                    mode = "n",
                    key = "<leader>env",
                    action = '<cmd>NRV<cr>',
                    desc = "Open NarrWin For Last VSelect Region",
                },
                {
                    mode = "n",
                    key = "<leader>end",
                    action = '<cmd>NUD<cr>',
                    desc = "Open SltDiff In 2 NarrWin",
                },
                {
                    mode = "n",
                    key = "<leader>enp",
                    action = '<cmd>NRP<cr>',
                    desc = "Mark A Region For Muilt-NarrWin",
                },
                {
                    mode = "n",
                    key = "<leader>enm",
                    action = '<cmd>NRM<cr>',
                    desc = "Create New Muilt-NarrWin",
                },
                {
                    mode = "n",
                    key = "<leader>enl",
                    action = '<cmd>NRL<cr>',
                    desc = "ReSlt Last Region And Open Again NarrWin",
                },

            }
        }
    }
}

return plugin
