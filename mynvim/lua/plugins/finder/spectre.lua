local plugin = {}

plugin.core = {
    'nvim-pack/nvim-spectre',
    dependencies = {{"nvim-lua/plenary.nvim"}},

    config = function() -- Specifies code to run after this plugin is loaded
        require('spectre').setup()
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = '<leader>ro', name = "Open"},
            keymaps = {
                { mode =  'n', key = '<leader>roo', action = '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
                { mode = 'n', key = '<leader>row', action = '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', desc = "Search current word"},
                { mode = 'v', key = '<leader>ros', action = '<esc><cmd>lua require("spectre").open_visual()<CR>', desc = "Search current word"},
                { mode = 'n', key = '<leader>rop', action = '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', desc = "Search on current file"},
            }
        },
        {
            tag = {key = '<leader>rd', name = "Doing"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>rdl",
                    action = "<cmd>lua require('spectre').toggle_line()<CR>",
                    desc = "toggle current line"
                },
                {
                    mode = "n",
                    key = "<cr>",
                    action = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                    desc = "goto current file"
                },
                {
                    mode = "n",
                    key = "<leader>rdq",
                    action = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                    desc = "send all item to quickfix"
                },
                {
                    mode = "n",
                    key = "<leader>rdc",
                    action = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                    desc = "input replace vim command"
                },
                {
                    mode = "n",
                    key = "<leader>rdh",
                    action = "<cmd>lua require('spectre').show_options()<CR>",
                    desc = "show option"
                },
                {
                    mode = "n",
                    key = "<leader>rdr",
                    action = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
                    desc = "replace current line"
                },
                {
                    mode = "n",
                    key = "<leader>rdR",
                    action = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                    desc = "replace all"
                },
                {
                    mode = "n",
                    key = "<leader>rdv",
                    action = "<cmd>lua require('spectre').change_view()<CR>",
                    desc = "change result view mode"
                },
                {
                    mode = "n",
                    key = "<leader>rde",
                    action = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
                    desc = "replace by sed (X)"
                },
                {
                    mode = "n",
                    key = "<leader>rdx",
                    action = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
                    desc = "replace by oxi (X)"
                },
                {
                    mode = "n",
                    key = "<leader>rdu",
                    action = "<cmd>lua require('spectre').toggle_live_update()<CR>",
                    desc = "update change when vim write file."
                },
                {
                    mode = "n",
                    key = "<leader>rdi",
                    action = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
                    desc = "toggle ignore case"
                },
                {
                    mode = "n",
                    key = "<leader>rdt",
                    action = "<cmd>lua require('spectre').change_options('hidden')<CR>",
                    desc = "toggle search hidden"
                },
            }
        }
    }
}
return plugin
