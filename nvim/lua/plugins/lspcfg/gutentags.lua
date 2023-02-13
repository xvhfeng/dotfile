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
    "preservim/tagbar",

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


     "let g:tagbar_position = 'botright'
     "let g:tagbar_autoclose = 1
      let g:tagbar_autofocus = 1
     let g:tagbar_width = max([25, winwidth(0) / 5])
     let g:tagbar_scopestrs = {
            \    'class': "\uf0e8",
            \    'const': "\uf8ff",
            \    'constant': "\uf8ff",
            \    'enum': "\uf702",
            \    'field': "\uf30b",
            \    'func': "\uf794",
            \    'function': "\uf794",
            \    'getter': "\ufab6",
            \    'implementation': "\uf776",
            \    'interface': "\uf7fe",
            \    'map': "\ufb44",
            \    'member': "\uf02b",
            \    'method': "\uf6a6",
            \    'setter': "\uf7a9",
            \    'variable': "\uf71b",
            \ }
     let g:tagbar_iconchars = ['▶', '▼']  "(default on Linux and Mac OS X)
     "let g:tagbar_autopreview = 1
     "let g:tagbar_previewwin_pos = "splitbelow"
    ]]
}

plugin.mapping = function()
    local mappings = require('core.keymapping')

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","s"},
        action = ":GscopeFind s <C-R><C-W><cr>",
        short_desc = "查看光标下符号的引用",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","g"},
        action = ":GscopeFind g <C-R><C-W><cr>",
        short_desc = "查看光标下符号的定义",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","c"},
        action = ":GscopeFind c <C-R><C-W><cr>",
        short_desc = "查找调用本函数的函数",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","w"},
        action = ":GscopeFind t <C-R><C-W><cr>",
        short_desc = "查找光标下的字符串",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","e"},
        action = ":GscopeFind e <C-R><C-W><cr>",
        short_desc = "使用egrep模式查找光标下的字符串",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","f"},
        action = ":GscopeFind f <C-R><C-W><cr>",
        short_desc = "查找光标下的文件",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","i"},
        action = ":GscopeFind i <C-R><C-W><cr>",
        short_desc = "查找哪些文件 include 了本文件",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","x"},
        action = ":GscopeFind d <C-R><C-W><cr>",
        short_desc = "此函数调用的函数",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","a"},
        action = ":GscopeFind a <C-R><C-W><cr>",
        short_desc = "找到当前符号被赋值的位置",
        silent = true,
        noremap = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g","z"},
        action = ":GscopeFind z <C-R><C-W><cr>",
        short_desc = "在Ctags数据库中找到当前光标下的文字",
        silent = true,
        noremap = true
    })


    mappings.register({
        mode = "n",
        key = {"<leader>", "g","o"},
        action = ":TagbarToggle<cr>",
        short_desc = "显示当前Buffer的Taglist",
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
