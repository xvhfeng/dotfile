local plugin = {}

plugin.core = {
    'kdheepak/lazygit.nvim',

    config = function()
        require("telescope").load_extension("lazygit")
    end,
}

return plugin
