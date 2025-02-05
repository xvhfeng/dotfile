local plugin = {}

plugin.core = {
    'kazhala/close-buffers.nvim',
    event = 'VeryLazy',
    keys = {
        { '<leader>do', '<cmd>:BWipeout other<CR>', desc = 'Delete other buffers.' },
    },
     config = function()
        require('close_buffers').setup({
            filetype_ignore = { 'NvimTree', 'tagbar' }, -- Filetype to ignore when running deletions
            file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
            file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
            preserve_window_layout = { 'this' },
            next_buffer_cmd = function(windows)
                require('bufferline').cycle(1)
                local bufnr = vim.api.nvim_get_current_buf()
    
                for _, window in ipairs(windows) do
                    vim.api.nvim_win_set_buf(window, bufnr)
                end
            end,
        })
    end
}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>do",
            action = '<cmd>:BWipeout other<CR>',
            desc = "Delete other buffers"
        }
    }
}

return plugin

--[[
-- bdelete
require('close_buffers').delete({ type = 'hidden', force = true }) -- Delete all non-visible buffers
require('close_buffers').delete({ type = 'nameless' }) -- Delete all buffers without name
require('close_buffers').delete({ type = 'this' }) -- Delete the current buffer
require('close_buffers').delete({ type = 1 }) -- Delete the specified buffer number
require('close_buffers').delete({ regex = '.*[.]md' }) -- Delete all buffers matching the regex

-- bwipeout
require('close_buffers').wipe({ type = 'all', force = true }) -- Wipe all buffers
require('close_buffers').wipe({ type = 'other' }) -- Wipe all buffers except the current focused
require('close_buffers').wipe({ type = 'hidden', glob = '*.lua' }) -- Wipe all buffers matching the glob
--]]