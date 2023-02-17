local plugin = {}


plugin.core = {
    "dense-analysis/ale",
    vim.cmd [==[
    " 关闭高亮提示
    let g:ale_set_highlights = 1
    "自定义error和warning图标
    let g:ale_sign_error = '✗'
    let g:ale_sign_warning = '⚡'
    "在vim自带的状态栏中整合ale
    let g:ale_statusline_format = ['✗ %d', '⚡ %d', '✔ OK']
    "显示Linter名称,出错或警告等相关信息
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    "打开文件时进行检查
    let g:ale_lint_on_enter = 1
    " 文件内容发生变化时不进行检查
    let g:ale_lint_on_text_changed = 'never'

    let g:ale_linters = {
    \   'python': ['pyflakes'],
    \   'c++': ['clang'],
    \   'c': ['clang'],
    \   'lua': ['luac']
    \}

    "普通模式下，sp前往上一个错误或警告，sn前往下一个错误或警告
    nmap sp <Plug>(ale_previous_wrap)
    nmap sn <Plug>(ale_next_wrap)
    "<Leader>s触发/关闭语法检查
    nmap <Leader>s :ALEToggle<CR>
    "<Leader>d查看错误或警告的详细信息
    nmap <Leader>d :ALEDetail<CR>

    ]==]

}

return plugin
