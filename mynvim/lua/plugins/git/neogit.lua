local plugin = {}

plugin.core = {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed, not both.
        "nvim-telescope/telescope.nvim", -- optional
        "ibhagwan/fzf-lua",              -- optional
    },
    config = true
}

--[[
plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>gg", name = "LazyGit"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>ggo",
                    action = "<cmd>LazyGit<cr>",
                    desc = "Show GitLazy"
                }, {
                    mode = "n",
                    key = "<leader>ggc",
                    action = "<cmd>LazyGitConfig<cr>",
                    desc = "Show LazyGit Config"
                }, {
                    mode = "n",
                    key = "<leader>ggf",
                    action = "<cmd>LazyGitCurrentFile<cr>",
                    desc = "Show Project GitInfo"
                }, {
                    mode = "n",
                    key = "<leader>ggb",
                    action = "<cmd>LazyGitFilter<cr>",
                    desc = "Git Current Buffer GitInfo"
                }
            }
        }
    }
}
--]]

return plugin
