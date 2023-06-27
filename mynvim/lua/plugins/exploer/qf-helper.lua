local plugin = {}

plugin.core = {
    "stevearc/qf_helper.nvim",
    name = "qf-helper",
    config = function()
        require('qf_helper').setup({
            prefer_loclist = true, -- Used for QNext/QPrev (see Commands below)
            sort_lsp_diagnostics = true, -- Sort LSP diagnostic results
            quickfix = {
                autoclose = true, -- Autoclose qf if it's the only open window
                default_bindings = true, -- Set up recommended bindings in qf window
                default_options = true, -- Set recommended buffer and window options
                max_height = 10, -- Max qf height when using open() or toggle()
                min_height = 1, -- Min qf height when using open() or toggle()
                track_location = 'cursor' -- Keep qf updated with your current location
                -- Use `true` to update position as well
            },
            loclist = { -- The same options, but for the loclist
                autoclose = true,
                default_bindings = true,
                default_options = true,
                max_height = 10,
                min_height = 1,
                track_location = 'cursor'
            }
        })
    end
}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<c-n>",
            action = '<cmd>QNext<CR>',
            desc = "QuickFix Next Item"
        },
        {
            mode = "n",
            key = "<c-p>",
            action = '<cmd>QPrev<CR>',
            desc = "QuickFix Prev Item"
        },

        {
            tag = {key = "<leader>wq", name = "QuickFix"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>wqt",
                    action = '<cmd>QFToggle!<CR>',
                    desc = "QuickFix Toggle"
                }, {
                    mode = "n",
                    key = "<leader>wql",
                    action = '<cmd>LLToggle!<CR>',
                    desc = "QuickFix Toggle"
                }
            }
        }
    }
}

return plugin

--[==[
Command	arg	description
QNext[!]	N=1	Go to next quickfix or loclist entry, choosing based on which is non-empty and which is open. Uses prefer_loclist option to tiebreak.
QPrev[!]	N=1	Go to previous quickfix or loclist entry, choosing based on which is non-empty and which is open. Uses prefer_loclist option to tiebreak.
QFNext[!]	N=1	Same as cnext, but wraps at the end of the list
QFPrev[!]	N=1	Same as cprev, but wraps at the beginning of the list
LLNext[!]	N=1	Same as lnext, but wraps at the end of the list
LLPrev[!]	N=1	Same as lprev, but wraps at the beginning of the list
QFOpen[!]		Same as copen, but dynamically sizes the window. With [!] cursor stays in current window.
LLOpen[!]		Same as lopen, but dynamically sizes the window. With [!] cursor stays in current window.
QFToggle[!]		Open or close the quickfix window. With [!] cursor stays in current window.
LLToggle[!]		Open or close the loclist window. With [!] cursor stays in current window.
Keep		(In qf buffer) Keep the item or range of items, remove the rest
Reject		(In qf buffer) Remove the item or range of items
Bindings
When default_bindings = true, the following keybindings are set in the quickfix/loclist buffer:

Key	Command
<C-t>	open in a new tab
<C-s>	open in a horizontal split
<C-v>	open in a vertical split
<C-p>	open the entry but keep the cursor in the quickfix window
<C-k>	scroll up and open entry while keeping the cursor in the quickfix window
<C-j>	scroll down and open entry while keeping the cursor in the quickfix window
{	scroll up to the previous file
}	scroll down to the next file

--]==]
