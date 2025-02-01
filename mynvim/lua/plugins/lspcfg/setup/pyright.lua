--[[
return {
    name = 'pylsp',
    setup_config = {
    }
}
--]]
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pylsp" },  -- 确保 pylsp 安装
  automatic_installation = true,
})

-- 配置 pylsp
require("lspconfig").pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pyflakes = { enabled = true },
        flake8 = { enabled = true },
      }
    }
  }
}


--[[
require'lspconfig'.pylsp.setup{
  on_attach = function(client, bufnr)
    -- 在此配置 pylsp 的其他功能，例如 keymaps
  end,
  settings = {
    pylsp = {
      plugins = {
        pyflakes = { enabled = true }, -- 启用 pyflakes 插件检查 Python 代码
        pydocstyle = { enabled = false }, -- 禁用 pydocstyle 插件
        jedi_completion = { enabled = true }, -- 启用 jedi 补全插件
        flake8 = { enabled = true }, -- 启用 flake8 插件
      }
    }
  },
}
--]]

vim.cmd [[
  autocmd FileType python lua require'lspconfig'.pylsp.setup{}
]]
