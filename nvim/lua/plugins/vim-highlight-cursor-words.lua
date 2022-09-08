local plugin = {}

plugin.core = {
    "pboettch/vim-highlight-cursor-words",
    as = "highlight-cursor-words",
    disable = false,
    opt=false,

    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.cmd [[
            let g:HiCursorWords_linkStyle='VisualNOS'
        ]]
    end,

    config = function() -- Specifies code to run after this plugin is loaded
  --      vim.api.nvim_set_keymap('n', 'j', '<Plug>(faster_move_j)', { noremap = false, silent = true })
  --      vim.api.nvim_set_keymap('n', 'k', '<Plug>(faster_move_k)', { noremap = false, silent = true })
    end
}

plugin.mapping = function()
end

return plugin