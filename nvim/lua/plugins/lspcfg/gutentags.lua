local plugin = {}

-- 预处理操作https://zhuanlan.zhihu.com/p/36279445
-- 参考:https://zhuanlan.zhihu.com/p/36279445
-- brew install --HEAD universal-ctags/universal-ctags/universal-ctags
-- brew install universal-ctags
-- brew install Global
-- cd /usr/local/share/gtags     
-- ln -s `pwd`/gtags.conf ~/.globalrc

plugin.core = {
    -- 使用gtags生成tags
    "xvhfeng/vim-gutentags",
    -- 智能切换多项目时的tags链接问题,保证项目中的应用不串
    "xvhfeng/gutentags_plus",

    vim.cmd [[
    " gutentags 搜索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
    let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

    " 所生成的数据文件的名称
    let g:gutentags_ctags_tagfile = '.tags'

    " 同时开启 ctags 和 gtags 支持：
    let g:gutentags_modules = []
    if executable('ctags')
    let g:gutentags_modules += ['ctags']
    endif
    if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
    endif

    " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
    let g:gutentags_cache_dir = expand('~/.cache/tags')

    " 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

    " 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
    let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

    " 禁用 gutentags 自动加载 gtags 数据库的行为
    let g:gutentags_auto_add_gtags_cscope = 0
    let g:gutentags_plus_nomap = 1
    noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
    noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
    noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
    noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
    noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
    noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
    noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
    noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>
    noremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>

    ]]
}

plugin.mapping = function()
    local mappings = require('core.keymapping')

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","s"},
        action = ":GscopeFind s <C-R><C-W><cr>",
        short_desc = "Find symbol (reference) under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","g"},
        action = ":GscopeFind g <C-R><C-W><cr>",
        short_desc = "Find symbol definition under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","c"},
        action = ":GscopeFind c <C-R><C-W><cr>",
        short_desc = "Functions calling this function",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","w"},
        action = ":GscopeFind t <C-R><C-W><cr>",
        short_desc = "Find text string under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","e"},
        action = ":GscopeFind e <C-R><C-W><cr>",
        short_desc = "Find egrep pattern under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","f"},
        action = ":GscopeFind f <C-R><C-W><cr>",
        short_desc = "Find file name under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","i"},
        action = ":GscopeFind i <C-R><C-W><cr>",
        short_desc = "Find files #including the file name under cursor",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","x"},
        action = ":GscopeFind d <C-R><C-W><cr>",
        short_desc = "Functions called by this function",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","a"},
        action = ":GscopeFind a <C-R><C-W><cr>",
        short_desc = "Find places where current symbol is assigned",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","z"},
        action = ":GscopeFind z <C-R><C-W><cr>",
        short_desc = "Find current word in ctags database",
        silent = true,
        noremap = true
    })



end

--[[

<leader>cg - 查看光标下符号的定义
<leader>cs - 查看光标下符号的引用
<leader>cc - 查看有哪些函数调用了该函数
<leader>cf - 查找光标下的文件
<leader>ci - 查找哪些文件 include 了本文件
<c-]>  跳转到函数定义
<c-o>  返回到刚刚跳转的地方
GscopeFind
--]]

return plugin
