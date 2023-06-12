local plugin = {}

plugin.core = {
    'kdheepak/lazygit.nvim',
    config = function()
        vim.g.lazygit_floating_window_winblend = 0 -- " transparency of floating window
        vim.g.lazygit_floating_window_scaling_factor = 0.9 -- " scaling factor for floating window
        vim.g.lazygit_floating_window_corner_chars = "['╭', '╮', '╰', '╯']" -- " customize lazygit popup window corner characters
        vim.g.lazygit_floating_window_use_plenary = 0 -- " use plenary.nvim to manage floating window if available
        vim.g.lazygit_use_neovim_remote = 1 -- " fallback to 0 if neovim-remote is not installed

        vim.g.lazygit_use_custom_config_file_path = 0 -- " config file path is evaluated if this value is 1
        vim.g.lazygit_config_file_path = '' -- " custom config file path
    end
}

plugin.mapping = {

    tags = {{
        key = "<leader>gl",
        desc = "+ LazyGit"
    }},
    keys = {{
        mode = "n",
        key = {"<leader>", "g", "l", "o"},
        action = ":LazyGit<cr>",
        short_desc = "Show GitLazy"
    }, {
        mode = "n",
        key = {"<leader>", "g", "l", "c"},
        action = ":LazyGitConfig<cr>",
        short_desc = "Show LazyGit Config"
    }, {
        mode = "n",
        key = {"<leader>", "g", "l", "p"},
        action = ":LazyGitCurrentFile<cr>",
        short_desc = "Show Project GitInfo"
    }, {
        mode = "n",
        key = {"<leader>", "g", "l", "b"},
        action = ":LazyGitFilter<cr>",
        short_desc = "Git Current Buffer GitInfo"
    }}
}

return plugin
