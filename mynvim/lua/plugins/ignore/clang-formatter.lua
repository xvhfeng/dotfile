local plugin = {}

plugin.core = {"rhysd/vim-clang-format"}

plugin.mapping = {
    keymaps = {
         {
            tag = {key = "<leader>ef", name = "Format"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>efc",
                    action = '<cmd>ClangFormat<cr>',
                    desc = "C/C++ Format",
                }
            }
        }
    }
}

return plugin
