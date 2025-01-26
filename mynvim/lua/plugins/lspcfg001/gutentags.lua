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
    {
        'ludovicchabant/vim-gutentags',
        after = "cscope_maps.nvim",
    }
    -- 智能切换多项目时的tags链接问题,保证项目中的应用不串
    {
        "xvhfeng/gutentags_plus",
        "preservim/tagbar",
    }


    config = function()
        -- https://www.reddit.com/r/vim/comments/d77t6j/guide_how_to_setup_ctags_with_gutentags_properly/
        vim.g.gutentags_ctags_exclude = {
            '*.git',
            '*.svg',
            '*.hg',
            '*/tests/*',
            'build',
            'dist',
            '*sites/*/files/*',
            'bin',
            'node_modules',
            'bower_components',
            'cache',
            'compiled',
            'docs',
            'example',
            'bundle',
            'vendor',
            '*.md',
            '*-lock.json',
            '*.lock',
            '*bundle*.js',
            '*build*.js',
            '.*rc*',
            '*.json',
            '*.min.*',
            '*.map',
            '*.bak',
            '*.zip',
            '*.pyc',
            '*.class',
            '*.sln',
            '*.Master',
            '*.csproj',
            '*.tmp',
            '*.csproj.user',
            '*.cache',
            '*.pdb',
            'tags*',
            'cscope.*',
            -- '*.css',
            -- '*.less',
            -- '*.scss',
            '*.exe',
            '*.dll',
            '*.mp3',
            '*.ogg',
            '*.flac',
            '*.swp',
            '*.swo',
            '*.bmp',
            '*.gif',
            '*.ico',
            '*.jpg',
            '*.png',
            '*.rar',
            '*.zip',
            '*.tar',
            '*.tar.gz',
            '*.tar.xz',
            '*.tar.bz2',
            '*.pdf',
            '*.doc',
            '*.docx',
            '*.ppt',
            '*.pptx',
        }

        vim.g.gutentags_modules = {"cscope_maps",'ctags','gtags_cscope'} -- This is required. Other config is optional
        vim.g.gutentags_cscope_build_inverted_index_maps = 1
        vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")
        vim.g.gutentags_file_list_command = "fd -e c -e h"
        vim.g.gutentags_add_default_project_roots = false
        vim.g.gutentags_project_root = { '.root','.project','package.json', '.git' }
        vim.g.gutentags_generate_on_new = true
        vim.g.gutentags_generate_on_missing = true
        vim.g.gutentags_generate_on_write = true
        vim.g.gutentags_generate_on_empty_buffer = true
        -- vim.g.gutentags_modules = true
        vim.cmd([[command! -nargs=0 GutentagsClearCache call system('rm ' . g:gutentags_cache_dir . '/*')]])
        -- vim.g.gutentags_ctags_extra_args = { '--tag-relative=yes', '--fields=+ailmnS', '--output-format=e-ctags','--c++-kinds=+px','--c-kinds=+px'}
        vim.g.gutentags_ctags_extra_args = { '--tag-relative=yes', '--fields=+ailmnS'}

        -- custom
        -- vim.g.gutentags_modules = { 'ctags','gtags_cscope' }
    end


    --[==[
    config = function()
        vim.cmd [[
    let $GTAGSCONF = '~/global.rc'
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
    end,
    --]==]
}

return plugin
