local plugin = {}

plugin.core = {
    -- 'nvim-treesitter/nvim-treesitter',
    'nvim-orgmode/orgmode',
    config = function()
        require('orgmode').setup_ts_grammar()

        -- Tree-sitter configuration
        require'nvim-treesitter.configs'.setup {
            -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = {'org'} -- Required for spellcheck, some LaTex highlights and code block highlights that do not have ts grammar
            },
            ensure_installed = {'org'} -- Or run :TSUpdate org
        }

        require('orgmode').setup({
            org_agenda_files = {'~/notes/org/*', '~/notes/my-orgs/**/*'},
            org_default_notes_file = '~/notes/org/refile.org'
        })
    end
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "o", "a"},
        action = nil,
        short_desc = "Org Agenda"

    }, {
        mode = "n",
        key = {"<leader>", "o", "c"},
        action = nil,
        short_desc = "Org Capture"

    }, {
        mode = "n",
        key = {"<leader>", "o", "x"},
        action = nil,
        short_desc = "Org Clock",
    }, {
        mode = "n",
        key = {"<leader>", "o", "x", "e"},
        action = nil,
        short_desc = "Org Effort Estimate"

    }, {
        mode = "n",
        key = {"<leader>", "o", "x", "i"},
        action = nil,
        short_desc = "Clock In"

    }, {
        mode = "n",
        key = {"<leader>", "o", "x", "o"},
        action = nil,
        short_desc = "Clock Out"

    }, {
        mode = "n",
        key = {"<leader>", "o", "x", "q"},
        action = nil,
        short_desc = "Clock Cancel"
    }, {
        mode = "n",
        key = {"<leader>", "o", "x", "j"},
        action = nil,
        short_desc = "Clock Goto"

    }, {
        mode = "n",
        key = {"c", "i", "r"},
        action = nil,
        short_desc = "Org Priority Down"

    }, {
        mode = {"n", 'x'},
        key = {"c", "i", "R"},
        action = nil,
        short_desc = "Org Priority Up"

    }, {
        mode = "n",
        key = {"c", "i", "t"},
        action = nil,
        short_desc = "Org Todo Status"

    }, {
        mode = "n",
        key = {"c", "i", "T"},
        action = nil,
        short_desc = "Org Todo Status"

    }, {
        mode = "n",
        key = {"c", "i", "d"},
        action = nil,
        short_desc = "Org Change Date"

    }, {
        mode = "n",
        key = {"<leader>", "o", "f"},
        action = nil,
        short_desc = "Org Open File"

    }, {
        mode = "n",
        key = {"<leader>", "o", "t"},
        action = nil,
        short_desc = "Org Tag"

    }, {
        mode = "n",
        key = {"<leader>", "o", "i"},
        action = nil,
        short_desc = "Org Insert"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "d"},
        action = nil,
        short_desc = "Org Insert DEADLINE"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "h"},
        action = nil,
        short_desc = "Org Insert Headline"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "s"},
        action = nil,
        short_desc = "Org Insert SCHEDULED"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "t"},
        action = nil,
        short_desc = "Org Insert TODO"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "."},
        action = nil,
        short_desc = "Org Insert Time Stamp"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", "T"},
        action = nil,
        short_desc = "Org Inplace Insert TODO"
    }, {
        mode = "n",
        key = {"<leader>", "o", "i", ","},
        action = nil,
        short_desc = "Org Insert Inactive Time Stamp"
    }, {
        mode = "n",
        key = {"<leader>", "o", "K"},
        action = nil,
        short_desc = "Org Move Up"
    }, {
        mode = "n",
        key = {"<leader>", "o", "J"},
        action = nil,
        short_desc = "Org Move Down"

    }, {
        mode = "n",
        key = {"<leader>", "o", "'"},
        action = nil,
        short_desc = "Org Edit Source"

    }, {
        mode = "n",
        key = {"<leader>", "o", "$"},
        action = nil,
        short_desc = "Org Archive Subtree"

    }, {
        mode = "n",
        key = {"<leader>", "o", "A"},
        action = nil,
        short_desc = "Org Archive Tag"
    }, {
        mode = "n",
        key = {"<leader>", "o", "r"},
        action = nil,
        short_desc = "Org Refile To"
    }, {
        mode = "n",
        key = {"<leader>", "o", "*"},
        action = nil,
        short_desc = "Org Toggle Headline"
    }, {
        mode = "n",
        key = {"<leader>", "o", ","},
        action = nil,
        short_desc = "Org Priority"
    }, {
        mode = "n",
        key = {"<leader>", "o", "e"},
        action = nil,
        short_desc = "Org Export(Emacs)"
    }}
}

return plugin
