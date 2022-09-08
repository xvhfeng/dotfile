local plugin = {}

plugin.core = {
    "danymat/neogen",
    opt_marker = "更方便的添加函数注释插件",
   opt_enable = false,


    after = { 'nvim-treesitter' },
    setup = function() -- Specifies code to run before this plugin is loaded.
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        if not packer_plugins['nvim-treesitter'].loaded then
            vim.cmd [[packadd nvim-treesitter]]
        end

        require('neogen').setup {
            enabled = true
        }
    end
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "n" },
        action = ":lua require('neogen').generate()<cr>",
        short_desc = "Generate Note",
        noremap = true,
        silent = true,
    })
end

return plugin
