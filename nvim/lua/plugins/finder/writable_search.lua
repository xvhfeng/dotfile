
local plugin = {}
-- brew install ack 
-- brew install ripgrep
-- not use ag, because install many deps-pkgs


plugin.core = {
    'AndrewRadev/writable_search.vim',
    vim.cmd([[

     " let g:writable_search_backends = ['ack.vim', 'rg --vimgrep --smart-case --column ']
    ]])
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "r","r" },
        action = ':WritableSearchFromQuickfix',
        short_desc = "Modify Searched TextString",
    })
end
return plugin
