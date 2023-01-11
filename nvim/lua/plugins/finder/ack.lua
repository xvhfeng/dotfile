
local plugin = {}
-- brew install ack 
-- brew install ripgrep
-- not use ag, because install many deps-pkgs

plugin.core = {
    "mileszs/ack.vim",
    as = "ack",
    vim.cmd([[
        if executable('ag')
            " let g:ackprg = 'ag --vimgrep --nogroup --column '
             "let g:ackprg = 'ack  '
            let g:ackprg = 'rg --vimgrep --smart-case --column ' 
        endif

        " 高亮搜索关键词
        let g:ackhighlight = 1
    ]])
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "r","a" },
        action = ':Ack! <space>',
        short_desc = "grep keywords",
    })
end
return plugin
--[==[
--:Ack [options] {pattern} [{directories}]
--说明：

默认情况下会递归搜索当前目录
pattern 支持正则
搜索的结果会显示在窗口中，显示的格式是文件名，内容在文件中的行数以及内容。在该窗口中回车 Enter 会直接跳到该文件中。

?    a quick summary of these keys, repeat to close
o    to open (same as Enter)
O    to open and close the quickfix window
go   to preview file, open but maintain focus on ack.vim results
t    to open in new tab
T    to open in new tab without moving to it
h    to open in horizontal split
H    to open in horizontal split, keeping focus on the results
v    to open in vertical split
gv   to open in vertical split, keeping focus on the results
q    to close the quickfix window
--]==]
