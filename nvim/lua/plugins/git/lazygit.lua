
local plugin = {}

plugin.core = {
    'kdheepak/lazygit.nvim',

    config = function()
        require("telescope").load_extension("lazygit")
    end,
}


plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.add_mapping_prefix("<leader>gz", {
        name = "+ LazyGit"
    })
    
    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "z","s"},
        action = ":LazyGit<cr>",
        short_desc = "Show Git by telescope",
        noremap = true,
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "z","c" },
        action = ":LazyGitCurrentFile<cr>",
        short_desc = "Show Git CurrentFile by telescope",
        noremap = true,
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "g", "z","f" },
        action = ":LazyGitCurrentFilter<cr>",
        short_desc = "Git CurrentFilter by telescope",
        noremap = true,
    })



end


return plugin
