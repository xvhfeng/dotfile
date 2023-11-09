-- 语言服务器
-- https://github.com/LuaLS/lua-language-server/releases
return {
    name = 'lua_ls',
    setup_config = {
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {'vim'},
                },
            },
        },
    },
}

