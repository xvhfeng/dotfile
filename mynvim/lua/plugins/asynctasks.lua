local plugin = {}

plugin.core = {
    -- "skywind3000/asynctasks.vim",
    "cstsunfu/asynctasks.vim", -- FIXME: when this buf fix, change to the default repo. https://github.com/skywind3000/asynctasks.vim/issues/92
    cmd = {"AsyncTask"},

    dependencies = {{"skywind3000/asyncrun.vim"}},

    config = function() -- Specifies code to run after this plugin is loaded
        vim.g.asynctasks_extra_config = {vim.g.CONFIG .. 'tasks.ini'}
        vim.g.asyncrun_open = 8
        vim.g.asyncrun_bell = 1
    end
}

--[[
plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "q", "b"},
            action = "<cmd>AsyncTask file-build<cr>",
            desc = "Quick Build"
        }, {
            mode = "n",
            key = {"<leader>", "q", "r"},
            action = "<cmd>AsyncTask file-run<cr>",
            desc = "Quick Run"
        }, {
            mode = "n",
            key = {"<leader>", "q", "g"},
            action = nil,
            desc = "Quick Grep"
        }, {
            mode = "n",
            key = {"<leader>", "q", "g", "c"},
            action = "<cmd>AsyncTask quickfix-rg-grep<cr>",
            desc = "Quick Grep Current Path"
        }, {
            mode = "n",
            key = {"<leader>", "q", "g", "p"},
            action = "<cmd>AsyncTask quickfix-rg-grep-project<cr>",
            desc = "Quick Grep Project Path"
        }, {
            mode = "n",
            key = {"<leader>", "q", "g", "f"},
            action = "<cmd>AsyncTask quickfix-rg-grep-filetype<cr>",
            desc = "Quick Grep Current Path File Types"
        }
    }
}
--]]

return plugin
