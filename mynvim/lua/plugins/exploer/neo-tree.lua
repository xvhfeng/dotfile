local plugin = {}

plugin.core = {
    "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
  }
}


plugin.mapping = {
    keymaps = {
        { mode = "n", key = "\\", action = '<cmd>Neotree<CR>', desc = "Open Floder Tree" },
        
    }
}

return plugin