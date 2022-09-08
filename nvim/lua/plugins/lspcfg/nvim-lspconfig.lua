local plugin = {}

plugin.core = {
    "neovim/nvim-lspconfig",
    disable = false,
    opt=false,

    as = "lspconfig",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()

    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "g", "d" },
        action = '<cmd>lua vim.lsp.buf.definition()<cr>',
        short_desc = "Goto Definition",
        silent = false
    })
    mappings.register({
        mode = "n",
        key = { "g", "D" },
        action = '<cmd>lua vim.lsp.buf.declaration()<cr>',
        short_desc = "Goto Declaration",
        silent = false
    })
    mappings.register({
        mode = "n",
        key = { "g", "r" },
        action = '<cmd>lua vim.lsp.buf.references()<cr>',
        short_desc = "Goto References",
        silent = false
    })
    mappings.register({
        mode = "n",
        key = { "g", "i" },
        action = '<cmd>lua vim.lsp.buf.implementation()<cr>',
        short_desc = "Goto Implementation",
        silent = false
    })

    mappings.register({
        mode = "n",
        key = { "K" },
        action = '<cmd>lua vim.lsp.buf.hover()<cr>',
        short_desc = "Displays Hover",
        desc = "Displays hover information about the symbol under the cursor in a floating window. Calling the function twice will jump into the floating window.",
        silent = false
    })
    mappings.register({
        mode = "n",
        key = { "<leader>", "s", "n" },
        action = '<cmd>lua vim.diagnostic.goto_next()<cr>',
        short_desc = "Prev Diagnostic",
        silent = true,
    })
    mappings.register({
        mode = "n",
        key = { "<C-p>" },
        action = '<cmd>lua vim.diagnostic.goto_prev()<cr>',
        short_desc = "Next Diagnostic",
        silent = false
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "=" },
        action = ":lua vim.lsp.buf.format()<cr>",
        short_desc = "Code Format"
    })


    mappings.register({
        mode = "n",
        key = { "<leader>", "s", "=" },
        action = ":% !npx sql-formatter --config='$HOME/.mynvim/sql_format.json'<cr>",
        short_desc = "Sql Format"
    })

    mappings.register({
        mode = "v",
        key = { "<leader>", "s", "=" },
        action = ": !npx sql-formatter --config='$HOME/.mynvim/sql_format.json'<cr>",
        short_desc = "Sql Format"
    })


    
--[===[
    -- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

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
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['pyright'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['rust_analyzer'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}
--]===]
end

return plugin