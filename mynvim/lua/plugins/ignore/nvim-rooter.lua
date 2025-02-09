local plugin = {}

plugin.core = {
    "notjedi/nvim-rooter.lua",
    config = function()
        require('nvim-rooter').setup {
            rooter_patterns = { '.root','.project','.git', '.hg', '.svn' },
            trigger_patterns = { '*' },
            -- 是否手动调用Rooter命令
            manual = false,
            -- 当文件没有根目录时，更改为文件目录
            fallback_to_parent = false,
        }
    end
}

return plugin
