

local plugin = {}

plugin.core = {
    "vim-scripts/Rename2",
}

plugin.mapping = {
    keys = { {
        mode = "n",
        key = { "<leader>", "f", "r" },
        action = ":Rename ",
        short_desc = "Rename current buffer filename.",
    }
}
}


return plugin

--[==[
    :Rename 命令
--]==]
