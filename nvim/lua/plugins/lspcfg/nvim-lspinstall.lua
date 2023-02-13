local plugin = {}


plugin.core = {
    'kabouzeid/nvim-lspinstall',

    require'lspinstall'.setup() -- important

local servers = require'lspinstall'.installed_servers()
for _, server in pairs(servers) do
    require'lspconfig'[server].setup{}
end

}

return plugin
