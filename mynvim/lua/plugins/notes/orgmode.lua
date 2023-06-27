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
            org_default_notes_file = '~/notes/org/refile.org',
            org_todo_keywords = { 'TODO(T)', 'WAIT(W)', '|', 'DONE(D)', "ASSIGN(A)", 'CANCEL(C)'},
            org_todo_keyword_faces = {
                TODO = ':foreground #FA7F08 :weight bold', -- overrides builtin color for `TODO` keyword
                WAIT= ':foreground #F24405 :weight bold',
                DONE = ':foreground #9EF8EE :weight bold', -- overrides builtin color for `TODO` keyword
                ASSIGN = ':foreground #22BABB :weight bold',
                CANCEL = ':foreground #348888 :weight bold', -- overrides builtin color for `TODO` keyword
            },
            org_deadline_warning_days = 7,
            org_agenda_min_height = 16,
            org_agenda_span = 'week', -- day/week/month/year/number of days
            org_agenda_start_on_weekday = 1,
            org_agenda_start_day = nil, -- start from today + this modifier
            org_capture_templates = {
                t = {
                    description = 'Default TODO',
                    template = '** TODO %?\n   SCHEDULED: %T\n   [[file:~/org/wiki/note/;.md]]',
                    target = '~/org/agenda/todo.org',
                },
                w = {
                    description = 'Work Weekly Plan',
                    template = '** TODO %?\n   SCHEDULED: %T\n   [[file:~/org/work/weekly/%<%Y>/%<%Y>_%<%W>.md][%<%Y>_%<%W>]]',
                    target = '~/org/work/weekly/todo.org',
                },
            },
            org_agenda_skip_scheduled_if_done = false,
            org_agenda_skip_deadline_if_done = false,
            org_agenda_text_search_extra_files = {},
            org_priority_highest = 'A',
            org_priority_default = 'B',
            org_priority_lowest = 'C',
            org_archive_location = '%s_archive::',
            org_use_tag_inheritance = true,
            org_tags_exclude_from_inheritance = {},
            org_hide_leading_stars = false,
            org_hide_emphasis_markers = false,
            org_ellipsis = '...',
            org_log_done = 'time',
            org_highlight_latex_and_related = nil,
            org_custom_exports = {},
            org_indent_mode = 'indent',
            org_time_stamp_rounding_minutes = 5,
            org_blank_before_new_entry = {
                heading = true,
                plain_list_item = false,
            },
            org_src_window_setup = 'top 20new',
            org_edit_src_content_indentation = 0,
            diagnostics = true,
            notifications = {
                enabled = false,
                cron_enabled = true,
                repeater_reminder_time = {1, 10},
                deadline_warning_reminder_time = false,
                reminder_time = 10,
                deadline_reminder = true,
                scheduled_reminder = true,
                notifier = function(tasks)
                    local result = {}
                    for _, task in ipairs(tasks) do
                        require('orgmode.utils').concat(result, {
                            string.format('# %s (%s)', task.category, task.humanized_duration),
                            string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title),
                            string.format('%s: <%s>', task.type, task.time:to_string())
                        })
                    end

                    if not vim.tbl_isempty(result) then
                        require('orgmode.notifications.notification_popup'):new({ content = result })
                    end
                end,
                cron_notifier = function(tasks)
                    for _, task in ipairs(tasks) do
                        local title = string.format('%s (%s)', task.category, task.humanized_duration)
                        local subtitle = string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
                        local date = string.format('%s: %s', task.type, task.time:to_string())
                        -- Linux
                        if vim.fn.executable('notify-send') == 1 then
                            vim.loop.spawn('notify-send', { args = { string.format('%s\n%s\n%s', title, subtitle, date) }})
                        elseif vim.fn.executable('terminal-notifier') == 1 then -- MacOS
                            vim.loop.spawn('terminal-notifier', { args = { '-title', title, '-subtitle', subtitle, '-message', date }})
                        end
                    end
                end
            }
        })
        vim.cmd[[autocmd FileType org setlocal iskeyword+=:,#,+]]
    end
}

--[[
plugin.mapping = {
    keymaps = {
        { tag = {key = "<leader>no",name = "OrgName"}},

        keymaps  = {
            {
                mode = "n",
                key = "<leader>", "o", "a",
                action = nil,
                desc = "Org Agenda"

            }, {
                mode = "n",
                key = "<leader>", "o", "c",
                action = nil,
                desc = "Org Capture"

            }, {
                mode = "n",
                key = "<leader>", "o", "x",
                action = nil,
                desc = "Org Clock",
            }, {
                mode = "n",
                key = "<leader>", "o", "x", "e",
                action = nil,
                desc = "Org Effort Estimate"

            }, {
                mode = "n",
                key = "<leader>", "o", "x", "i",
                action = nil,
                desc = "Clock In"

            }, {
                mode = "n",
                key = "<leader>", "o", "x", "o",
                action = nil,
                desc = "Clock Out"

            }, {
                mode = "n",
                key = "<leader>", "o", "x", "q",
                action = nil,
                desc = "Clock Cancel"
            }, {
                mode = "n",
                key = "<leader>", "o", "x", "j",
                action = nil,
                desc = "Clock Goto"

            }, {
                mode = "n",
                key = "c", "i", "r",
                action = nil,
                desc = "Org Priority Down"

            }, {
                mode = {"n", 'x'},
                key = "c", "i", "R",
                action = nil,
                desc = "Org Priority Up"

            }, {
                mode = "n",
                key = "c", "i", "t",
                action = nil,
                desc = "Org Todo Status"

            }, {
                mode = "n",
                key = "c", "i", "T",
                action = nil,
                desc = "Org Todo Status"

            }, {
                mode = "n",
                key = "c", "i", "d",
                action = nil,
                desc = "Org Change Date"

            }, {
                mode = "n",
                key = "<leader>", "o", "f",
                action = nil,
                desc = "Org Open File"

            }, {
                mode = "n",
                key = "<leader>", "o", "t",
                action = nil,
                desc = "Org Tag"

            }, {
                mode = "n",
                key = "<leader>", "o", "i",
                action = nil,
                desc = "Org Insert"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", "d",
                action = nil,
                desc = "Org Insert DEADLINE"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", "h",
                action = nil,
                desc = "Org Insert Headline"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", "s",
                action = nil,
                desc = "Org Insert SCHEDULED"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", "t",
                action = nil,
                desc = "Org Insert TODO"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", ".",
                action = nil,
                desc = "Org Insert Time Stamp"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", "T",
                action = nil,
                desc = "Org Inplace Insert TODO"
            }, {
                mode = "n",
                key = "<leader>", "o", "i", ",",
                action = nil,
                desc = "Org Insert Inactive Time Stamp"
            }, {
                mode = "n",
                key = "<leader>", "o", "K",
                action = nil,
                desc = "Org Move Up"
            }, {
                mode = "n",
                key = "<leader>", "o", "J",
                action = nil,
                desc = "Org Move Down"

            }, {
                mode = "n",
                key = "<leader>", "o", "'",
                action = nil,
                desc = "Org Edit Source"

            }, {
                mode = "n",
                key = "<leader>", "o", "$",
                action = nil,
                desc = "Org Archive Subtree"

            }, {
                mode = "n",
                key = "<leader>", "o", "A",
                action = nil,
                desc = "Org Archive Tag"
            }, {
                mode = "n",
                key = "<leader>", "o", "r",
                action = nil,
                desc = "Org Refile To"
            }, {
                mode = "n",
                key = "<leader>", "o", "*",
                action = nil,
                desc = "Org Toggle Headline"
            }, {
                mode = "n",
                key = "<leader>", "o", ",",
                action = nil,
                desc = "Org Priority"
            }, {
                mode = "n",
                key = "<leader>", "o", "e",
                action = nil,
                desc = "Org Export(Emacs)"
            }}
    }
}

--]]
return plugin
