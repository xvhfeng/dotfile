
local plugin = {}

plugin.core = {
    --'xvhfeng/vim-antlr',  
    'Joakker/vim-antlr4',
    config  = function()
        vim.cmd[[
        au BufRead,BufNewFile *.g set filetype=antlr3
        au BufRead,BufNewFile *.g4 set filetype=antlr4 
        ]]
    end
}


return plugin
