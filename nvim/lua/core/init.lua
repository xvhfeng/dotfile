--[===[
vim.g.feature_groups = {
    default = true,
    lsp = "builtin", --"builtin" or "coc" or set to nil/false to disable lsp
    --lsp = "coc", --"builtin" or "coc" or set to nil/false to disable lsp
    colorschemes = true,
    beauty_vim = true,
    file_and_view = true,
    special_for_language = true,
    debug_adapter = true,
    org_my_life = true,
    enhance = true,
    git = true,
}
--]===]

--"builtin" or "coc" or set to nil/false to disable lsp
--"coc", --"builtin" or "coc" or set to nil/false to disable lsp
vim.g.lspcfg = "builtin"

require('core.default')
pcall(require, "core.local") -- local maybe not exists
require('core.user')
require('core.plugins').setup()
require('core.plugins').create_mapping()
require('core.keymapping').setup()
require("plugins." .. vim.g.colorscheme).setup(vim.g.style)
require('core.after')
