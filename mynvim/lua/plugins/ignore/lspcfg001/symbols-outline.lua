local plugin = {}

plugin.core = {
    'simrat39/symbols-outline.nvim',
    config = function()
        require("symbols-outline").setup()
    end,

}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>lst",
            action = "<cmd>SymbolsOutline<CR>",
            desc = "Symbols Outline"
        }}
}

return plugin
