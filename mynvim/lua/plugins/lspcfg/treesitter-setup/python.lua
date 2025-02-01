require'nvim-treesitter.configs'.setup {
    ensure_installed = "python",  -- 确保安装了 python 解析器
    highlight = {
        enable = true,  -- 启用语法高亮
    },
    indent = {
        enable = true,  -- 启用自动缩进
    },
    vim.cmd("autocmd BufRead,BufNewFile *.py set filetype=python"),
}
