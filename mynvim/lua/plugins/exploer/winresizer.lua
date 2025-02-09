local plugin = {}

plugin.core = {
	--    'simeji/winresizer',
	--   config = function() vim.g.winresizer_gui_enable = 1 end

	"mrjones2014/smart-splits.nvim",
	config = function()
		require("smart-splits").setup({})

		-- recommended mappings
		-- resizing splits
		-- these keymaps will also accept a range,
		-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
		--vim.keymap.set("n", "<M-h>", require("smart-splits").resize_left)
		--vim.keymap.set("n", "<M-j>", require("smart-splits").resize_down)
		--vim.keymap.set("n", "<M-k>", require("smart-splits").resize_up)
		--vim.keymap.set("n", "<M-l>", require("smart-splits").resize_right)
		vim.keymap.set("n", "<leader>ws", require("smart-splits").start_resize_mode)
		vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
		-- moving between splits
		--vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
		--vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
		--vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
		--vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
		-- swapping buffers between windows
		--vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
		--vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
		--vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
		--vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
	end,
}

--plugin.mapping = {
--    keymaps = {
--        {
--            mode = "n",
--            key = "<leader>ws",
--            action = "<cmd>WinResizerStartResize<cr>",
--            desc = "Resize Windows",
--        },
--    },
--}

--[[
Start 'window resize mode', and you can resize current vim windows using 'h', 'j', 'k', 'l' keys
You want to finish resize mode, then press "Enter" key
If you cancel window resize, then press "q" key. You will get window size of before change
You can change the mode if you press "e" in 'window resize mode'
----]]
return plugin
