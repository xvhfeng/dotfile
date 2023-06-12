local plugin = {}

plugin.core = {
    "dense-analysis/ale",
    config = function()
        -- 关闭高亮提示
        vim.g.ale_set_highlights = 1
        -- "自定义error和warning图标
        vim.g.ale_sign_error = '✗'
        vim.g.ale_sign_warning = '⚡'
        -- "在vim自带的状态栏中整合ale
        vim.g.ale_statusline_format = "['✗ %d', '⚡ %d', '✔ OK']"
        -- "显示Linter名称,出错或警告等相关信息
        vim.g.ale_echo_msg_error_str = 'E'
        vim.g.ale_echo_msg_warning_str = 'W'
        vim.g.ale_echo_msg_format = '[%linter%] %s [%severity%]'
        -- "打开文件时进行检查
        vim.g.ale_lint_on_enter = 1
        -- " 文件内容发生变化时不进行检查
        vim.g.ale_lint_on_text_changed = 'never'

        vim.g.ale_linters = {{
            ['python'] = 'pyflakes'
        }, {
            ['c++'] = 'clang'
        }, {
            ['c'] = 'clang'
        }, {
            ['lua'] = 'luac'
        }}
    end

}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"s", "p"},
        action = 'ale_previous_wrap'
    }, {
        mode = "n",
        key = {"s", "n"},
        action = 'ale_next_wrap'
    }, {
        mode = "n",
        key = {"<leader>", "s"},
        action = ':ALEToggle<CR>',
        desc = "触发/关闭语法检查"
    }, {
        mode = "n",
        key = {"<leader>", "d"},
        action = ':ALEDetail<CR>',
        desc = '查看错误或警告的详细信息'
    }}
}

return plugin
