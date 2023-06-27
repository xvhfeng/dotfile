local plugin = {}

plugin.core = {"vim-scripts/Rename2"}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>br",
            action = ":Rename [newname]",
            desc = "Rename current buffer filename."
        }
    }
}

return plugin

--[==[
    :Rename 命令
--]==]
