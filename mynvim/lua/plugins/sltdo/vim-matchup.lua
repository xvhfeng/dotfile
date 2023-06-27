local plugin = {}

plugin.core = {
    'andymass/vim-matchup',
    config = function()
--        vim.builtin.treesitter.matchup.enable = true
    end,
    init = function()
        -- may set any options here
        vim.g.matchup_matchparen_offscreen = {method = "popup"}
    end
}


--[[
Note: match-up uses the same b:match_words as matchit.
Adds motions g%, [%, ]%, and z%.
Combines these motions into convenient text objects i% and a%.
Highlights symbols and words under the cursor which % can work on, and highlights matching symbols and words. Now you can easily tell where % will jump to.
--]]

return plugin
