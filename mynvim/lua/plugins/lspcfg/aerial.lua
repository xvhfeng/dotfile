local plugin = {}

plugin.core = {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },

}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>lso",
            action = "<cmd>AerialToggle<CR>",
            desc = "Aerial Outline"
        }}
}

return plugin
