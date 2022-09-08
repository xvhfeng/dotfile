local plugin = {}

plugin.core = {
    "nvim-neorg/neorg",
    opt_marker = "org的升级版",
    ft = "norg",
    after = { 'nvim-treesitter' },
    opt_enable = false,

    requires = {
        {"nvim-lua/plenary.nvim"},
    },
    
    
    setup = function() -- Specifies code to run before this plugin is loaded.
       
    end,
        
    config = function() -- Specifies code to run after this plugin is loaded

        require('neorg').setup {
            load = {
                ["core.defaults"] = {},
                ["core.norg.dirman"] = {
                    config = {
                        workspaces = {
                            work = "~/notes/work",
                            home = "~/notes/home",
                        }
                    }
                },
                ["core.norg.completion"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                        -- Configuration here
                    }
                 },
                 ["core.integrations.treesitter"] = {
                    config = { -- Note that this table is optional and doesn't need to be provided
                        -- Configuration here
                    }
                 }
            }
        }

       -- if not packer_plugins['nvim-treesitter'].loaded then
        --    vim.cmd [[packadd nvim-treesitter]]
       -- end

        require('nvim-treesitter.configs').setup {
            ensure_installed = { "norg", --[[ other parsers you would wish to have ]] },
            highlight = { -- Be sure to enable highlights if you haven't!
                enable = true,
            }
        }
    end,
}

plugin.mapping = function()
    
end

return plugin
