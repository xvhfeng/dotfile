local plugin = {}

plugin.core = {
    -- 多多少少，mason.nvim的github上的配置在我机器上有点问题
    -- 所以取消mason与lspconfig的lazy load，直接启动就加载
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "williamboman/mason.nvim",
            lazy = false,
        },{
            "williamboman/mason-lspconfig.nvim",
            lazy = false,
        }
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"lua_ls",
                "bashls",
                "jdtls",
                "clangd",
                "pyright",
                "cmake",
                "eslint",
                "jsonls",
                "tsserver",
                "marksman",
                "sqlls",
                "yamlls",
                "vimls",
                "gopls"
            },
            automatic_installation = true
        })

        -- 下述的lsp.lsconfig-xxx，都是lsp文件夹下的各种文件
        local config_tb = {
            require "plugins/lspcfg/setup/bashls",
            require "plugins/lspcfg/setup/clangd",
            require "plugins/lspcfg/setup/cmake",
            require "plugins/lspcfg/setup/eslint",
            require "plugins/lspcfg/setup/gopls",
            require "plugins/lspcfg/setup/jdtls",
            require "plugins/lspcfg/setup/lua_ls",
            require "plugins/lspcfg/setup/marksman",
            require "plugins/lspcfg/setup/pyright",
            require "plugins/lspcfg/setup/sqll",
            require "plugins/lspcfg/setup/tsserver",
            require "plugins/lspcfg/setup/vimls",
            require "plugins/lspcfg/setup/yamlls",
        }
        --
        local lspconfig = require('lspconfig')
        for _, cfg in ipairs(config_tb) do
            -- 取到配置
            local setup_config = cfg.setup_config
            -- 为每一个语言服务进行setup
            lspconfig[cfg.name].setup(setup_config)
        end
    end
}

return plugin
