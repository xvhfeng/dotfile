local plugin = {}

plugin.core = {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup({
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified
      });
    end
}

-- plugin.mapping = {
--     keysmaps = {
--         { 'n', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'n', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'n', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'n', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {} },

--         { 'x', '*', [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'x', '#', [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'x', 'g*', [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {} },
--         { 'x', 'g#', [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {} }


--         --[[
--         {mode = "n", key = "*", action = '<Plug>(asterisk-*)',desc = "No Desc" },
--         {mode = "n", key = "#", action = '<Plug>(asterisk-#)',desc = "No Desc" },
--         {mode = "n", key = "g*", action = '<Plug>(asterisk-g*)',desc = "No Desc" },
--         {mode = "n", key = "g#", action = '<Plug>(asterisk-g#)',desc = "No Desc" },
--         {mode = "n", key = "z*", action = '<Plug>(asterisk-z*)',desc = "No Desc" },
--         {mode = "n", key = "gz*", action = '<Plug>(asterisk-gz*)',desc = "No Desc"},
--         {mode = "n", key = "z#", action = '<Plug>(asterisk-z#)',desc = "No Desc" },
--         {mode = "n", key = "gz#", action = '<Plug>(asterisk-gz#)',desc = "No Desc"},
--     --]]
--     }
-- }

return plugin
