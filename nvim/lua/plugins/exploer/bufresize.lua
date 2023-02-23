local plugin = {}

plugin.core = {

    'mrjones2014/smart-splits.nvim',
    config = function()

        require('smart-splits').setup({
            -- Ignored filetypes (only while resizing)
            ignored_filetypes = {
                'nofile',
                'quickfix',
                'prompt',
            },
            -- Ignored buffer types (only while resizing)
            ignored_buftypes = { 
                'nofile',
            },
            -- the default number of lines/columns to resize by at a time
            default_amount = 3,
            -- whether to wrap to opposite side when cursor is at an edge
            -- e.g. by default, moving left at the left edge will jump
            -- to the rightmost window, and vice versa, same for up/down.
            wrap_at_edge = true,
            -- when moving cursor between splits left or right,
            -- place the cursor on the same row of the *screen*
            -- regardless of line numbers. False by default.
            -- Can be overridden via function parameter, see Usage.
            move_cursor_same_row = false,
            -- resize mode options
            resize_mode = {
                -- key to exit persistent resize mode
                quit_key = '<ESC>',
                -- keys to use for moving in resize mode
                -- in order of left, down, up' right
                resize_keys = { 'h', 'j', 'k', 'l' },
                -- set to true to silence the notifications
                -- when entering/exiting persistent resize mode
                silent = false,
                -- must be functions, they will be executed when
                -- entering or exiting the resize mode
                hooks = {
                    on_enter = nil,
                    on_leave = nil,
                },
            },
            -- ignore these autocmd events (via :h eventignore) while processing
            -- smart-splits.nvim computations, which involve visiting different
            -- buffers and windows. These events will be ignored during processing,
            -- and un-ignored on completed. This only applies to resize events,
            -- not cursor movement events.
            ignored_events = {
                'BufEnter',
                'WinEnter',
            },
            -- enable or disable the tmux integration
            tmux_integration = true,
            -- disable tmux navigation if current tmux pane is zoomed
            disable_tmux_nav_when_zoomed = true,
        })
    end,

}

plugin.mapping  = function()

    -- resizing splits
    -- amount defaults to 3 if not specified
    -- use absolute values, no + or -
    -- the functions also check for a range,
    -- so for example if you bind `<A-h>` to `resize_left`,
    -- then `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
    require('smart-splits').resize_up(amount)
    require('smart-splits').resize_down(amount)
    require('smart-splits').resize_left(amount)
    require('smart-splits').resize_right(amount)
    -- moving between splits
    -- pass same_row as a boolean to override the default
    -- for the move_cursor_same_row config option.
    -- See Configuration.
    require('smart-splits').move_cursor_up()
    require('smart-splits').move_cursor_down()
    require('smart-splits').move_cursor_left(same_row)
    require('smart-splits').move_cursor_right(same_row)
    -- Swapping buffers directionally with the window to the specified direction
    require('smart-splits').swap_buf_up()
    require('smart-splits').swap_buf_down()
    require('smart-splits').swap_buf_left()
    require('smart-splits').swap_buf_right()
    -- persistent resize mode
    -- temporarily remap your configured resize keys to
    -- smart resize left, down, up, and right, respectively,
    -- press <ESC> to stop resize mode (unless you've set a different key in config)
    -- resize keys also accept a range, e.e. pressing `5j` will resize down 5 times the default_amount
    require('smart-splits').start_resize_mode()
    local opts = { noremap=true, silent=true }
    -- recommended mappings
    -- resizing splits
    -- these keymaps will also accept a range,
    -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
    vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left,opt)
    vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down,opt)
    vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up,opt)
    vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right,opt)
    -- moving between splits
    --vim.keymap.set('n', '<A-H>', require('smart-splits').move_cursor_left,opt)
    --vim.keymap.set('n', '<A-J>', require('smart-splits').move_cursor_down,opt)
    --vim.keymap.set('n', '<A-K>', require('smart-splits').move_cursor_up,opt)
    --vim.keymap.set('n', '<A-L>', require('smart-splits').move_cursor_right,opt)
    -- swapping buffers between windows
    vim.keymap.set('n', '<A-H>', require('smart-splits').swap_buf_left,opt)
    vim.keymap.set('n', '<A-J>', require('smart-splits').swap_buf_down,opt)
    vim.keymap.set('n', '<A-K>', require('smart-splits').swap_buf_up,opt)
    vim.keymap.set('n', '<A-L>', require('smart-splits').swap_buf_right,opt)
end
return plugin
