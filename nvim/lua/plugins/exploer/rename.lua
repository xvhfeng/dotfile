

local plugin = {}

plugin.core = {
    "vim-scripts/Rename2",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "f", "r" },
        action = ":Rename ",
        short_desc = "Rename current buffer filename.",
        silent = true
    })

end

return plugin

--[==[
    :Rename 命令
--]==]
