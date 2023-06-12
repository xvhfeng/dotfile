local plugin = {}

plugin.core = {
    'junegunn/fzf',
    "junegunn/fzf.vim",

    config = function()
        -- This is the default option:
        --   - Preview window on the right with 50% width
        --   - CTRL-/ will toggle preview window.
        -- - Note that this array is passed as arguments to fzf#vim#with_preview function.
        -- - To learn more about preview window options, see `--preview-window` section of `man fzf`.
        vim.g.fzf_preview_window = "['right,50%', 'ctrl-/']"

        -- Preview window is hidden by default. You can toggle it with ctrl-/.
        -- It will show on the right with 50% width, but if the width is smaller
        -- than 70 columns, it will show above the candidate list
        vim.g.fzf_preview_window = "['hidden,right,50%,<70(up,40%)', 'ctrl-/']"

        -- Empty value to disable preview window altogether
        vim.g.fzf_preview_window = "[]"

        -- [Buffers] Jump to the existing window if possible
        vim.g.fzf_buffers_jump = 1

        -- [[B]Commits] Customize the options used by 'git log':
        vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

        -- [Tags] Command to generate tags file
        vim.g.fzf_tags_command = 'ctags -R'

        -- [Commands] --expect expression for directly executing the command
        vim.g.fzf_commands_expect = 'alt-enter,ctrl-x'
    end

}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "f", "z"},
        action = ":BTags<CR>",
        short_desc = "Show current buffer Tags."
    }}
}

return plugin
