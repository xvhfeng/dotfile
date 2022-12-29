
local plugin = {}

--[==[
    Requirements
    nvim 0.4+ or vim 8.2
    ripgrep 11.0.0+ or ag
--]==]

plugin.core = {
    'pechorin/any-jump.vim',
    as = "any-jump",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = {"n","v"},
        key = { "<leader>","j" },
        action = ':AnyJump<CR>',
        short_desc = "Jump to definition under cursor",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>","a","b" },
        action = ':AnyJumpBack<CR>',
        short_desc = "open previous opened file (after jump)",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>","a" ,"l"},
        action = '::AnyJumpLastResults<CR>',
        short_desc = "open last closed search window again",
    })
end

--[==[
o/<CR>     open
s          open in split
v          open in vsplit
t          open in new tab
p/<tab>    preview
q/x        exit
r          references
b          back to first result
T          group by file
a          load next N results
A          load all results
L          toggle results lists ui style
--]==]

return plugin

