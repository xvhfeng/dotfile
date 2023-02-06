local plugin = {}


local opts = { noremap=true, silent=true }
vim.keymap.set('n', 'ge', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', 'gq', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', 'gwa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', 'gwr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', 'gwl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', 'gtD', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'grn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', 'gca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gmt', function() vim.lsp.buf.format { async = true } end, bufopts)
end


plugin.core = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",

    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        },

        keymaps = {
            -- Keymap to expand a package
            toggle_package_expand = "<CR>",
            -- Keymap to install the package under the current cursor position
            install_package = "i",
            -- Keymap to reinstall/update the package under the current cursor position
            update_package = "u",
            -- Keymap to check for new version for the package under the current cursor position
            check_package_version = "c",
            -- Keymap to update all installed packages
            update_all_packages = "U",
            -- Keymap to check which installed packages are outdated
            check_outdated_packages = "C",
            -- Keymap to uninstall a package
            uninstall_package = "X",
            -- Keymap to cancel a package installation
            cancel_installation = "<C-c>",
            -- Keymap to apply language filter
            apply_language_filter = "<C-f>",
        },
    }),

    require("mason-lspconfig").setup({
        ensure_installed = {
            "sumneko_lua",
            "clangd",
            "gopls",
            "golangci_lint_ls",
            "rust_analyzer",
            "awk_ls",
            "clangd",
            "jsonls",
            "bashls",
            "tsserver",
            "sqlls",
            "pyright",
        },
    }),

    require'lspconfig'.clangd.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require'lspconfig'.gopls.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require'lspconfig'.awk_ls.setup{},
    require'lspconfig'.bashls.setup{},
    require'lspconfig'.golangci_lint_ls.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require'lspconfig'.jsonls.setup{},
    require'lspconfig'.sqlls.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require'lspconfig'.sumneko_lua.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }
    require'lspconfig'.tsserver.setup{}
    require'lspconfig'.pyright.setup{
        on_attach = on_attach,
        flags = lsp_flags,
    }

}

return plugin

--[===[
    :Mason - opens a graphical status window
    :MasonInstall <package> ... - installs/reinstalls the provided packages
    :MasonUninstall <package> ... - uninstalls the provided packages
    :MasonUninstallAll - uninstalls all packages
    :MasonLog - opens the mason.nvim log file in a new tab window
--]===]
