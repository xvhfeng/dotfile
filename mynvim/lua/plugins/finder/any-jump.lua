local plugin = {}

--[==[
    Requirements
    nvim 0.4+ or vim 8.2
    ripgrep 11.0.0+ or ag
--]==]

plugin.core = {'pechorin/any-jump.vim'}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>fj", name = "JumpTo"},
            keymaps = {
                {
                    mode = {"n", "v"},
                    key = "<leader>fjd",
                    action = '<cmd>AnyJump<CR>',
                    desc = "JumpTo Definition CWORD"
                }, {
                    mode = "n",
                    key = "<leader>fjb",
                    action = '<cmd>AnyJumpBack<CR>',
                    desc = "Back Previous Opened File (After Jump)"
                }, {
                    mode = "n",
                    key = "<leader>fjl",
                    action = '<cmd>AnyJumpLastResults<CR>',
                    desc = "Reopen Last Closed Search Window"
                }
            }
        }
    }
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
