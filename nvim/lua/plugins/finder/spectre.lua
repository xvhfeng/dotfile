local plugin = {}

plugin.core = {
    "windwp/nvim-spectre",
    requires = {
        {"nvim-lua/plenary.nvim"},
    },

    config = function() -- Specifies code to run after this plugin is loaded
        if not packer_plugins['plenary.nvim'].loaded then
            vim.cmd [[packadd plenary.nvim]]
        end
        require('spectre').setup()
    end,

}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    --nnoremap <leader>S :lua require('spectre').open()<CR>
    mappings.register({
        mode = "n",
        key = {"<leader>", "r", "s","r"},
        action = ":lua require('spectre').open()<CR>",
        short_desc = "Search By Reg Exp.",
        silent = true
    })


    mappings.register({
        mode = "n",
        key = {"<leader>", "r","s", "c"},
        action = ":lua require('spectre').open_visual({select_word=true})<CR>",
        short_desc = "Search By Reg Exp.",
        silent = true
    })


    mappings.register({
        mode = "n",
        key = {"<leader>","r", "s", "w"},
        action = ":lua require('spectre').open_visual()<CR>",
        short_desc = "Search By Reg Exp.",
        silent = true
    })


    mappings.register({
        mode = "n",
        key = {"<leader>","r", "s", "f"},
        action = ":lua require('spectre').open_file_search()<cr>",
        short_desc = "Search By Reg Exp.",
        silent = true
    })
end
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
