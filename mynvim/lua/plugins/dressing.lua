local M = {}

--M.core = {
--    "stevearc/dressing.nvim",
--    config = function()
--        require("dressing").setup({
--            input = {
--                enabled = true,
--                default_prompt = "➤ ",
--                title_pos = "center",
--                border = "rounded", -- 可选: "single", "double", "rounded", "none"
--                relative = "editor", -- 让输入框相对于整个编辑器居中
--                prefer_width = 80, -- 设定输入框的宽度
--                win_options = {
--                    winblend = 10, -- 透明度（0-100）
--                },
--            },
--        })
--    end,
--}

M.core = {
	"stevearc/dressing.nvim",
	opts = {
		input = {
			enabled = true,
			default_prompt = "➤ ",
			title_pos = "center",
			border = "rounded",
			relative = "win", -- 让输入框居中
			prefer_width = 40,
			win_options = {
				winblend = 10,
			},
		},
	},
}

return M
