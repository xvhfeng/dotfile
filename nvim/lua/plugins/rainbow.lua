local plugin = {}

plugin.core = {
    "luochen1990/rainbow",
    as = "rainbow",
    disable = false,
    opt=false,

    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.cmd [[
            let g:rainbow_active = 1
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