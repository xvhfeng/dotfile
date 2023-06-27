local plugin = {}

plugin.core = {
    'fcpg/vim-kickfix',
}

plugin.mapping = {
    keymaps = {
        {
            tag = { key = "<leader>wq", name = "QuickFix"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>wqd",
                    action = '<cmd>QDeleteLine<CR>',
                    desc = "Delete CLine QuickFix"
                },
                {
                    mode = "n",
                    key = "<leader>wqf",
                    action = '<cmd>QFilterName <CWORD><CR>',
                    desc = "Keep If CWORD In Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wqF",
                    action = '<cmd>QFilterName! <CWORD><CR>',
                    desc = "Keep If CWORD NotIn Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wqa",
                    action = ':QFilterName [pattern]',
                    desc = "Keep If [Pattern] In Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wqA",
                    action = ':QFilterName! [pattern]',
                    desc = "Keep If [pattern] NotIn Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wqc",
                    action = '<cmd>QFilterContent <CWORD><CR>',
                    desc = "Keep If CWORD In Content"
                },
                {
                    mode = "n",
                    key = "<leader>wqC",
                    action = '<cmd>QFilterContent! <CWORD><CR>',
                    desc = "Keep If CWORD NotIn Content"
                },
                {
                    mode = "n",
                    key = "<leader>wqa",
                    action = ':QFilterContent [pattern]',
                    desc = "Keep If [Pattern] In Content"
                },
                {
                    mode = "n",
                    key = "<leader>wqA",
                    action = ':QFilterContent! [pattern]',
                    desc = "Keep If [pattern] NotIn Content"
                },
                {
                    mode = "n",
                    key = "<leader>wqi",
                    action = '<cmd>QInfo<cr>',
                    desc = "Show NumbOfFiles And NumbOfEntries"
                },
                {
                    mode = "n",
                    key = "<leader>wql",
                    action = ':QLoad [path]',
                    desc = "Load QuickFix Fron [path]"
                },

            }
        },
        {
            tag = { key = "<leader>wl", name = "LocList"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>wld",
                    action = '<cmd>QDeleteLine<CR>',
                    desc = "Delete CLine LocList"
                },
                {
                    mode = "n",
                    key = "<leader>wlf",
                    action = '<cmd>LocFilterName <CWORD><CR>',
                    desc = "Keep If CWORD In Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wlF",
                    action = '<cmd>LocFilterName! <CWORD><CR>',
                    desc = "Keep If CWORD NotIn Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wla",
                    action = ':LocFilterName [pattern]',
                    desc = "Keep If [Pattern] In Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wlA",
                    action = ':LocFilterName! [pattern]',
                    desc = "Keep If [pattern] NotIn Filename"
                },
                {
                    mode = "n",
                    key = "<leader>wlc",
                    action = '<cmd>LocFilterContent <CWORD><CR>',
                    desc = "Keep If CWORD In Content"
                },
                {
                    mode = "n",
                    key = "<leader>wlC",
                    action = '<cmd>LocFilterContent! <CWORD><CR>',
                    desc = "Keep If CWORD NotIn Content"
                },
                {
                    mode = "n",
                    key = "<leader>wla",
                    action = ':LocFilterContent [pattern]',
                    desc = "Keep If [Pattern] In Content"
                },
                {
                    mode = "n",
                    key = "<leader>wlA",
                    action = ':LocFilterContent! [pattern]',
                    desc = "Keep If [pattern] NotIn Content"
                },
                {
                    mode = "n",
                    key = "<leader>wli",
                    action = '<cmd>QInfo<cr>',
                    desc = "Show NumbOfFiles And NumbOfEntries"
                },
                {
                    mode = "n",
                    key = "<leader>wll",
                    action = ':QLoad [path]',
                    desc = "Load LocList Fron [path]"
                },

            }
        }
    }
}

return plugin


--[==[
    :[range]QDeleteLine                                              *:QDeleteLine*
  Delete lines from the quickfix buffer and the corresponding entries
  from the quickfix list. Also works for the location list.

:QFilterName[!] {pattern}                                        *:QFilterName*
  Keep only filenames matching {pattern} in the quickfix list.
  Discard them if [!].

:LocFilterName[!] {pattern}                                    *:LocFilterName*
  Keep only filenames matching {pattern} in the location list.
  Discard them if [!].

:QFilterContent[!] {pattern}                                  *:QFilterContent*
  Keep only files whose content matches {pattern} in the quickfix list.
  Discard them if [!].

:LocFilterContent[!] {pattern}                              *:LocFilterContent*
  Keep only files whose content matches {pattern} in the location list.
  Discard them if [!].

:QInfo                                                                 *:QInfo*
  Show number of files and number of entries in the quickfix list. Also works
  for the location list.

:QLoad {path}                                                          *:QLoad*
  Load quickfix from {path}.
  Quickfix content can be saved as is with `:w {path}`. Also works for the
  location list.

=============================================================================
PLUG MAPPINGS                                           *kickfix-plug-mappings*

<Plug>(KickfixPreview)
  Open quickfix entry in preview window. Buffer-local.
  Cf. |kickfix-example|

--]==]
