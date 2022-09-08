local plugin = {}

plugin.core = {
    "jose-elias-alvarez/null-ls.nvim", -- TODO: currently, this plugin is WIP, so will update this when this plugin provide more sources
    requires = { "nvim-lua/plenary.nvim" },

    config = function() -- Specifies code to run after this plugin is loaded
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.diagnostics.eslint,
                null_ls.builtins.completion.spell,
                null_ls.builtins.completion.luasnip ,
                null_ls.builtins.completion.tags,
                null_ls.builtins.diagnostics.codespell ,
                null_ls.builtins.diagnostics.cppcheck,
                null_ls.builtins.diagnostics.credo,
                null_ls.builtins.diagnostics.gitlint,
                null_ls.builtins.diagnostics.gdlint ,
                null_ls.builtins.diagnostics.golangci_lint,
                null_ls.builtins.diagnostics.jsonlint,
                null_ls.builtins.diagnostics.markdownlint ,
                null_ls.builtins.diagnostics.mypy,
                null_ls.builtins.diagnostics.pylint.with({
                    diagnostics_postprocess = function(diagnostic)
                      diagnostic.code = diagnostic.message_id
                    end,
                  }),
                null_ls.builtins.diagnostics.textlint,

                null_ls.builtins.formatting.isort,
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.buf ,
                null_ls.builtins.formatting.clang_format,
                null_ls.builtins.formatting.cmake_format,
                null_ls.builtins.formatting.eslint,
                null_ls.builtins.formatting.fixjson,
                null_ls.builtins.formatting.gofmt,
                null_ls.builtins.formatting.gofumpt,
                null_ls.builtins.formatting.goimports,
                null_ls.builtins.formatting.goimports_reviser,
                null_ls.builtins.formatting.golines,
                null_ls.builtins.formatting.json_tool,
                null_ls.builtins.formatting.lua_format ,
                null_ls.builtins.formatting.rustfmt,
                null_ls.builtins.formatting.shfmt,
                null_ls.builtins.formatting.sqlformat,
            },
        })
    end,
}

plugin.mapping = function()
end
return plugin
