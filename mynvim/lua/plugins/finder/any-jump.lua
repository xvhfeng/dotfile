local plugin = {}

--[==[
    Requirements
    nvim 0.4+ or vim 8.2
    ripgrep 11.0.0+ or ag
--]==]

plugin.core = {
    'pechorin/any-jump.vim',
}

plugin.mapping = {
    keys = {{
        mode = {"n", "v"},
        key = {"<leader>", "r", "j"},
        action = ':AnyJump<CR>',
        short_desc = "Jump to definition under cursor"
    }, {
        mode = "n",
        key = {"<leader>", "r", "b"},
        action = ':AnyJumpBack<CR>',
        short_desc = "open previous opened file (after jump)"
    }, {
        mode = "n",
        key = {"<leader>", "r", "l"},
        action = '::AnyJumpLastResults<CR>',
        short_desc = "open last closed search window again"
    }}
}

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

