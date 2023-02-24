local plugin = {}

plugin.core = {

    'mrjones2014/smart-splits.nvim',
    config = function()

        require('smart-splits').setup({
            -- Ignored filetypes (only while resizing)
            ignored_filetypes = {
                'neo-tree',
                'nvim-tree',
                'nofile',
                'quickfix',
                'prompt',
            },
            -- Ignored buffer types (only while resizing)
            ignored_buftypes = { 
                'neo-tree',
                'nvim-tree',
            },
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
    --require('smart-splits').resize_up(amount)
    --require('smart-splits').resize_down(amount)
    --require('smart-splits').resize_left(amount)
    --require('smart-splits').resize_right(amount)
    -- moving between splits
    -- pass same_row as a boolean to override the default
    -- for the move_cursor_same_row config option.
    -- See Configuration.
    --require('smart-splits').move_cursor_up()
    --require('smart-splits').move_cursor_down()
    --require('smart-splits').move_cursor_left(same_row)
    --require('smart-splits').move_cursor_right(same_row)
    -- Swapping buffers directionally with the window to the specified direction
    --require('smart-splits').swap_buf_up()
    --require('smart-splits').swap_buf_down()
    --require('smart-splits').swap_buf_left()
    --require('smart-splits').swap_buf_right()
    -- persistent resize mode
    -- temporarily remap your configured resize keys to
    -- smart resize left, down, up, and right, respectively,
    -- press <ESC> to stop resize mode (unless you've set a different key in config)
    -- resize keys also accept a range, e.e. pressing `5j` will resize down 5 times the default_amount
    --require('smart-splits').start_resize_mode()
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
