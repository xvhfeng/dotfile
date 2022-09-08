local plugin = {}

plugin.core = {
    -- need install "brew install glow"
    "ellisonleao/glow.nvim",
    opt_marker = "直接在nvim的终端中预览markdown",
   opt_enable = true,



    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.g.glow_border = "rounded"
        --vim.g.glow_width = 120
        --vim.g.glow_use_pager = true
        vim.g.glow_width = vim.fn.winwidth(0)
        if vim.g.style == 'light' then
            vim.g.glow_style = "light"
        else
            vim.g.glow_style = "dark"
        end
    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "m", "t" },
        action = ":Glow<cr>:resize +1000<cr>:vertical resize +1000<cr>",
        short_desc = "Quick Build",
        silent = true,
    })


end
return plugin
