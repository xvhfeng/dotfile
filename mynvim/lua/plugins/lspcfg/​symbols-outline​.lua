local plugin = {}

plugin.core = {
    'simrat39/symbols-outline.nvim',
    config = function()
        require("symbols-outline").setup()
    end,

}

plugin.mapping = {
    keys = { 
    {
        mode = {"n"},
        key = {"<leader>", "l", "o"},
        action = "<cmd>SymbolsOutline<CR>",
        short_desc = "Outline"
    }}
}

return plugin
