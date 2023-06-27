local plugin = {}

plugin.core = {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup {
            direction = 'float'
        }
    end
}

--[[  
local lazydocker = nil
function _lazydocker_toggle()
    lazydocker = lazydocker or require('plugins.containers.lazydocker-inc')
    lazydocker.toggle()
end

, {
                mode = "n",
                key = "<leader>stc",
                action = '<cmd>lua _lazydocker_toggle()<cr>',
                desc = "Lazydocker Toggle"
            }
            
--]]

plugin.mapping = {
    keymaps = {
        {
            tag = {
                key = "<leader>st",
                name = "Term"
            },
            keymaps = {{
                mode = "n",
                key = "<leader>sto",
                action = '<cmd>ToggleTerm<cr>',
                desc = "Open Toggle Term"
            }}
        }
    }
}

return plugin
