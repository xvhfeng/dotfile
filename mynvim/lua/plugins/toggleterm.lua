local plugin = {}

plugin.core = {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup{
        direction = 'float'
        }
    end
}

local lazydocker = nil
function _lazydocker_toggle()
    lazydocker = lazydocker or require('plugins.containers.lazydocker')
    lazydocker.toggle()
end

plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "t", "o"},
            action = '<cmd>ToggleTerm<cr>',
            short_desc = "Open Toggle Term"
        }, {
            mode = "n",
            key = {"<leader>", "t", "c"},
            action = '<cmd>lua _lazydocker_toggle()<cr>',
            short_desc = "Lazydocker Toggle"
        }
    }
}

return plugin


