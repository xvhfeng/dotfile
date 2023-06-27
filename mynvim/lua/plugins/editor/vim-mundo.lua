local plugin = {}

plugin.core = {
    'simnalamburt/vim-mundo',

    config = function()
        vim.g.mundo_width = 60
        vim.g.mundo_preview_height = 40
        vim.g.mundo_right = 1
        vim.cmd [[
            set undofile
            set undodir=~/.vim/undo
            ]]
    end
}

--[[
@ -- current position in undotree
0 -- not current position
j/k -- move up/down 
gg/G -- top/bottom of the graph
<return> -- revert the contents of file to match that state
p -- preview the diff between curent state and selected stats
P -- PlayTo target at te state is not useful
q -- quit
--]]

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>eh", name = "UndoTree"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>eht",
                    action = '<cmd>MundoToggle<cr>',
                    desc = "MUndoTree Toggle"
                }
            }
        }
    }
}

return plugin
