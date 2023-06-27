local plugin = {}

plugin.core = {
    "windwp/nvim-spectre",
    dependencies = {{"nvim-lua/plenary.nvim"}},

    config = function() -- Specifies code to run after this plugin is loaded
        require('spectre').setup()
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>fr", name = "Search&Replace With Preview"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>fro",
                    action = ":lua require('spectre').open()<CR>",
                    desc = "Open Search"
                }, {
                    mode = "n",
                    key = "<leader>frc",
                    action = ":lua require('spectre').open_visual({select_word=true})<CR>",
                    desc = "Search CWord"
                }, {
                    mode = "n",
                    key = "<leader>frv",
                    action = ":lua require('spectre').open_visual()<CR>",
                    desc = "Open Seach Visual"
                }, {
                    mode = "n",
                    key = "<leader>frf",
                    action = ":lua require('spectre').open_file_search()<cr>",
                    desc = "Search In CurrentFile"

                }, {
                    mode = "n",
                    key = "<leader>frt",
                    action = ":lua require('spectre').toggle_line()<cr>",
                    desc = "Toggle Current Item"
                }, {
                    mode = "n",
                    key = "<leader>frg",
                    action = ":lua require('spectre').select_entry()<cr>",
                    desc = "Goto CurrentFile"
                }, {
                    mode = "n",
                    key = "<leader>frr",
                    action = ":lua require('spectre').run_current_replace()<cr>",
                    desc = "Replace CurrentLine"
                }, {
                    mode = "n",
                    key = "<leader>fra",
                    action = ":lua require('spectre').run_repalce()<cr>",
                    desc = "Replace All"
                }, {
                    mode = "n",
                    key = "<leader>fri",
                    action = ":lua require('spectre').change_options('ignore-case')<cr>",
                    desc = "Toggle IgnoreCase"
                }, {
                    mode = "n",
                    key = "<leader>frp",
                    action = ":lua require('spectre').change_view()<cr>",
                    desc = "Update Result ViewMode"
                }, {
                    mode = "n",
                    key = "<leader>frh",
                    action = ":lua require('spectre').resume_last_search()<cr>",
                    desc = "Resume Last Search"
                }
            }
        }
    }
}
return plugin

--[===[
mapping={
    ['toggle_line'] = {
        map = "dd",
        cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
        desc = "toggle current item"
    },
    ['enter_file'] = {
        map = "<cr>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        desc = "goto current file"
    },
    ['send_to_qf'] = {
        map = "<leader>q",
        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
        desc = "send all item to quickfix"
    },
    ['replace_cmd'] = {
        map = "<leader>c",
        cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
        desc = "input replace vim command"
    },
    ['show_option_menu'] = {
        map = "<leader>o",
        cmd = "<cmd>lua require('spectre').show_options()<CR>",
        desc = "show option"
    },
    ['run_current_replace'] = {
      map = "<leader>rc",
      cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
      desc = "replace current line"
    },
    ['run_replace'] = {
        map = "<leader>R",
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
        desc = "replace all"
    },
    ['change_view_mode'] = {
        map = "<leader>v",
        cmd = "<cmd>lua require('spectre').change_view()<CR>",
        desc = "change result view mode"
    },
    ['change_replace_sed'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
      desc = "use sed to replace"
    },
    ['change_replace_oxi'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
      desc = "use oxi to replace"
    },
    ['toggle_live_update']={
      map = "tu",
      cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
      desc = "update change when vim write file."
    },
    ['toggle_ignore_case'] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "toggle ignore case"
    },
    ['toggle_ignore_hidden'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "toggle search hidden"
    },
----]===]
