local plugin = {}

plugin.core = {
    "dhananjaylatkar/cscope_maps.nvim",
    dependencies = {
        "folke/which-key.nvim", -- optional [for whichkey hints]
        "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
        "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
        "nvim-tree/nvim-web-devicons", -- optional [for devicons in telescope or fzf]
    },
    opts = {
        disable_maps = false, -- "true" disables default keymaps
        skip_input_prompt = false, -- "true" doesn't ask for input

        -- cscope related defaults
        cscope = {
            -- location of cscope db file
            db_file = "./cscope.out",
            -- cscope executable
            exec = "cscope", -- "cscope" or "gtags-cscope"
            -- choose your fav picker
            picker = "quickfix", -- "telescope", "fzf-lua" or "quickfix"
            -- "true" does not open picker for single result, just JUMP
            skip_picker_for_single_result = false, -- "false" or "true"
            -- these args are directly passed to "cscope -f <db_file> <args>"
            db_build_cmd_args = { "-bqkv" },
            -- statusline indicator, default is cscope executable
            statusline_indicator = nil,
            -- USE EMPTY FOR DEFAULT OPTIONS
            -- DEFAULTS ARE LISTED BELOW
        },
    },
    config = function()
        require("cscope_maps").setup()
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = { key = "<leader>lj",name = "Cscope"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>ljs",
                    -- action = "<cmd>GscopeFind s <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('s', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find symbol (reference) under cursor"
                }, {
                    mode = "n",
                    key = "<leader>ljg",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('g', vim.fn.expand("<cword>"))<cr>]],
                    -- action = "<cmd>GscopeFind g <C-R><C-W><cr>",
                    desc = "Find symbol definition under cursor"
                }, {
                    mode = "n",
                    key = "<leader>ljc",
                    -- action = "<cmd>GscopeFind c <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('c', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Functions calling this function"
                }, {
                    mode = "n",
                    key = "<leader>ljw",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('t', vim.fn.expand("<cword>"))<cr>]],
                    -- action = "<cmd>GscopeFind t <C-R><C-W><cr>",
                    desc = "Find text string under cursor"
                }, {
                    mode = "n",
                    key = "<leader>lje",
                    -- action = "<cmd>GscopeFind e <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('e', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find egrep pattern under cursor"
                }, {
                    mode = "n",
                    key = "<leader>ljf",
                    --action = "<cmd>GscopeFind f <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('f', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find file name under cursor"
                }, {
                    mode = "n",
                    key = "<leader>lji",
                    -- action = "<cmd>GscopeFind i <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('i', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find files including the file name under cursor"
                }, {
                    mode = "n",
                    key = "<leader>ljx",
                    --action = "<cmd>GscopeFind d <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('d', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Functions called by this function"
                }, {
                    mode = "n",
                    key = "<leader>lja",
                    -- action = "<cmd>GscopeFind a <C-R><C-W><cr>",
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('a', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find places where current symbol is assigned"
                }, {
                    mode = "n",
                    key = "<leader>ljz",
                    -- action = "<cmd>GscopeFind z <C-R><C-W><cr>",,
                    action = [[<cmd>lua require('cscope_maps').cscope_prompt('z', vim.fn.expand("<cword>"))<cr>]],
                    desc = "Find current word in ctags database"
                }, {
                    mode = "n",
                    key = "<leader>ljo",
                    action = "<cmd>TagbarToggle<cr>",
                    desc = "Show Current Buffer Taglist"
                }
            }
        }
    }
}
return plugin
