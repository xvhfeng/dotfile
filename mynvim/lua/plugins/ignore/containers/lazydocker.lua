local plugin = {}

plugin.core = {only_keymapping}

local lazydocker = nil
function _lazydocker_toggle()
    lazydocker = lazydocker or require('plugins.containers.lazydocker-inc')
    lazydocker.toggle()
end

plugin.mapping = {
    keymaps = {
        {
            tag = {
                key = "<leader>cd",
                name = "Docker"
            },
            keymaps = {{
                mode = "n",
                key = "<leader>cdz",
                action = '<cmd>lua _lazydocker_toggle()<cr>',
                desc = "LazyDocker Toggle"
            }}
        }
    }
}

return plugin