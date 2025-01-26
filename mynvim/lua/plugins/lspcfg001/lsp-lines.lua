local plugin = {}

plugin.core = {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
        require("lsp_lines").setup()
    end,
}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>lst",
            action = "<cmd>lua require('lsp_lines').toggle<CR>",
            desc = "Toggle lsp-lines"
        }}
}

return plugin
