
local plugin = {}

plugin.core = {
    'kdheepak/lazygit.nvim',

    vim.cmd [[
        let g:lazygit_floating_window_winblend = 0 " transparency of floating window
let g:lazygit_floating_window_scaling_factor = 0.9 " scaling factor for floating window
let g:lazygit_floating_window_corner_chars = ['╭', '╮', '╰', '╯'] " customize lazygit popup window corner characters
let g:lazygit_floating_window_use_plenary = 0 " use plenary.nvim to manage floating window if available
let g:lazygit_use_neovim_remote = 1 " fallback to 0 if neovim-remote is not installed

let g:lazygit_use_custom_config_file_path = 0 " config file path is evaluated if this value is 1
let g:lazygit_config_file_path = '' " custom config file path




    ]]

}


plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.add_mapping_prefix("<leader>gl", {
        name = "+ LazyGit"
    })
    
    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "l","o"},
        action = ":LazyGit<cr>",
        short_desc = "Show GitLazy",
        noremap = true,
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "l","c" },
        action = ":LazyGitConfig<cr>",
        short_desc = "Show LazyGit Config",
        noremap = true,
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "l","p" },
        action = ":LazyGitCurrentFile<cr>",
        short_desc = "Show Project GitInfo",
        noremap = true,
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "l","b" },
        action = ":LazyGitFilter<cr>",
        short_desc = "Git Current Buffer GitInfo",
        noremap = true,
    })



end


return plugin
