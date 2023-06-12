local plugin = {}

plugin.core = {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.0",
    -- event = { "VimEnter" },
    dependencies = {{"nvim-lua/popup.nvim"}, {"nvim-lua/plenary.nvim"}, {"tami5/sqlite.lua"}, {"tami5/sql.nvim"},
                    {"nvim-telescope/telescope-frecency.nvim"}, {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    }, {"ahmedkhalf/project.nvim"}},

    config = function() -- Specifies code to run after this plugin is loaded

        local actions = require('telescope.actions')
        --[[
        require 'telescope'.load_extension('project')
        --]]
        local action_state = require("telescope.actions.state")

        local custom_actions = {}

        function custom_actions.fzf_multi_select(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local num_selections = table.getn(picker:get_multi_selection())

            if num_selections > 1 then
                -- actions.file_edit throws - context of picker seems to change
                -- actions.file_edit(prompt_bufnr)
                actions.send_selected_to_qflist(prompt_bufnr)
                actions.open_qflist()
            else
                actions.file_edit(prompt_bufnr)
            end
        end

        require('telescope').setup {
            defaults = {
                vimgrep_arguments = {'rg', '--color=never', '--no-heading', '--with-filename', '--line-number',
                                     '--column', '--smart-case'},
                prompt_prefix = " ",
                selection_caret = "➤ ",
                entry_prefix = "  ",
                -- initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "descending",
                layout_strategy = "horizontal",
                history = {
                    path = '~/.local/share/nvim/telescope_history.sqlite3'
                },
                layout_config = {
                    horizontal = {
                        mirror = false
                    },
                    vertical = {
                        mirror = false
                    }
                },
                file_sorter = require'telescope.sorters'.get_fuzzy_file,
                file_ignore_patterns = {},
                generic_sorter = require'telescope.sorters'.get_generic_fuzzy_sorter,
                winblend = 0,
                border = {},
                borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'},
                color_devicons = true,
                use_less = true,
                path_display = {},
                set_env = {
                    ['COLORTERM'] = 'truecolor'
                }, -- default = nil,
                file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
                grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
                qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

                -- Developer configurations: Not meant for general override
                buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-o>"] = custom_actions.fzf_multi_select,
                        ["<C-j>"] = actions.cycle_history_next,
                        ["<C-k>"] = actions.cycle_history_prev
                    },
                    n = {
                        ["<esc>"] = actions.close,
                        ["<C-o>"] = custom_actions.fzf_multi_select
                    }
                }
            },
            extensions = {
                frecency = {
                    show_scores = false,
                    show_unindexed = true,
                    ignore_patterns = {"*.git/*"},
                    workspaces = {}
                },
                --[[
                project = {
                    base_dirs = {
                        '~/.mynvim',
                        '~/org',
                        '~/.dotfiles',
                        '~/workspace',
                    },
                    hidden_files = true -- default: false
                },
                    --]]
                -- TODO: switch fuzzy and exact, currently use the telescope-fzf-native
                -- https://github.com/nvim-telescope/telescope.nvim/issues/930
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case" -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                }
            }
        }
        require'telescope'.load_extension('fzf')
        require"telescope".load_extension("frecency")

        require("project_nvim").setup {
            patterns = {".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json"}
        }
        require('telescope').load_extension('projects')
        -- require'telescope'.extensions.projects.projects{}
    end
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "f", "f"},
        action = "<cmd>lua require('telescope.builtin').find_files()<cr>",
        short_desc = "Find files"
    }, {
        mode = "n",
        key = {"<leader>", "f", "q"},
        action = "<cmd>lua require('telescope.builtin').live_grep()<cr>",
        short_desc = "grep string"
    }, {
        mode = "n",
        key = {"<leader>", "f", "l"},
        action = "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({skip_empty_lines=true})<cr>",
        short_desc = "Find Lines"
    }, {
        mode = "n",
        key = {"<leader>", "f", "b"},
        action = "<cmd>lua require('telescope.builtin').buffers()<cr>",
        short_desc = "Find Buffers"
    }, {
        mode = "n",
        key = {"<leader>", "f", "c"},
        action = "<cmd>lua require('telescope.builtin').command_history()<cr>",
        short_desc = "Find Command History"
    }, {
        mode = "n",
        key = {"<leader>", "f", "w"},
        action = "<cmd>lua require 'telescope.builtin'.find_files{ cwd = vim.g.HOME_PATH .. '/org/wiki'}<cr>",
        short_desc = "Find Wiki"
    }, {
        mode = "n",
        key = {"<leader>", "f", "j"},
        action = "<cmd>lua require 'telescope.builtin'.find_files{ cwd = vim.g.HOME_PATH .. '/org/work'}<cr>",
        short_desc = "Find Wiki"
    }, {
        mode = "n",
        key = {"<leader>", "f", "h"},
        action = "<Cmd>lua require('telescope').extensions.frecency.frecency{ sorter = require('telescope.config').values.file_sorter()}<CR>",
        short_desc = "Find Recent/History"
    }, --[[
    {
        mode = "n",
        key = { "<leader>", "f", "p" },
        action = "<Cmd>lua require'telescope'.extensions.project.project{}<CR>",
        short_desc = "Find Project",
        silent = true,
        noremap = true
   },
    --]] {
        mode = "n",
        key = {"<leader>", "f", "k"},
        action = "<cmd>lua require('telescope.builtin').keymaps()<cr>",
        short_desc = "Find All Mappings"
    }, {
        mode = "n",
        key = {"<leader>", "f", ";"},
        action = nil,
        short_desc = "Find More"
    }, {
        mode = "n",
        key = {"<leader>", "f", "r"},
        action = "<cmd>lua require('telescope.builtin').registers()<cr>",
        short_desc = "Find Registers"
    }, {
        mode = "n",
        key = {"<leader>", "f", "i"},
        action = "<cmd>lua require('telescope.builtin').highlights()<cr>",
        short_desc = "Find Highlights"
    }, {
        mode = "n",
        key = {"<leader>", "f", "s"},
        action = "<cmd>lua require('telescope.builtin').colorscheme()<cr>",
        short_desc = "Find Themes"
    }, {
        mode = "n",
        key = {"<leader>", "f", "e"},
        action = "<cmd>lua require('telescope.builtin').planets()<cr>",
        short_desc = "Find Planets"
    }, {
        mode = "n",
        key = {"<leader>", "f", "g"},
        action = "<cmd>lua require('telescope.builtin').git_commits()<cr>",
        short_desc = "Find Git Commits"
    }, {
        mode = "n",
        key = {"<leader>", "f", "G"},
        action = "<cmd>lua require('telescope.builtin').git_bcommits()<cr>",
        short_desc = "Find Git Commits(buffer)"
    }, {
        mode = "n",
        key = {"<leader>", "f", "j"},
        action = "<cmd>lua require('telescope.builtin').jumplist()<cr>",
        short_desc = "Find Jump List"
    }, {
        mode = "n",
        key = {"<leader>", "f", "m"},
        action = "<cmd>lua require('telescope.builtin').marks()<cr>",
        short_desc = "Find Marks"
    }}
}

return plugin
