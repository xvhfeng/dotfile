local plugin = {}

plugin.core = {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup()
    end
}

local systerm = nil
local Terminal  = nil
function _systerm_new()
    Terminal = require('toggleterm.terminal').Terminal
    systerm = Terminal:new({
        cmd = "source ~/.bashrc",
        dir = "git_dir",
        direction = "float",
        float_opts = {
            border = "double",
        },
    })
end

function _systerm_toggle()
    if nil == systerm then 
        _systerm_new()
    end
    if nil ~= systerm then
        systerm:toggle()
    end
end


plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "t", "b"},
            action = '<cmd>lua _systerm_toggle()<cr>',
            short_desc = "System BashTerm Toggle"
        }, {
            mode = "n",
            key = {"<leader>", "t", "c"},
            action = '<cmd>lua _lazydocker_toggle()<cr>',
            short_desc = "LzayDocker Toggle"
        }
    }
}

return plugin
