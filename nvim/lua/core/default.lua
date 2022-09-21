

local default_setting = {}


default_setting['global'] = {
    after_schedule_time_start = 500,
  
}

-- setting map leader

vim.cmd("let maplocalleader=','")
vim.cmd("let mapleader=','")
vim.cmd("nnoremap ; :")
--vim.cmd("vnoremap \\ ;")
local global_func = require('util.global')


-- special setting

--vim.cmd("hi CursorLine term=bold cterm=bold guibg=Grey40") -- cursorline color

vim.g.no_number_filetypes = {
    dapui_stacks = true,
    dapui_breakpoints = true,
    dapui_watches = true,
    dapui_scopes = true,
    qf = true,
}
vim.g.no_number_filetypes_list = {}
for key, _ in pairs(vim.g.no_number_filetypes) do
    table.insert(vim.g.no_number_filetypes_list, key)
end

local no_number_filetypes_list = "dapui_stacks,dapui_breakpoints,dapui_watches,dapui_scopes,qf" -- why table.concat not work?

global_func.augroup('smarter_cursorline', {
    {
        events = { 'filetype' },
        targets = { no_number_filetypes_list },
        command = "setlocal nonumber"
    },
    {
        events = { 'filetype' },
        targets = { no_number_filetypes_list },
        command = "setlocal norelativenumber"
    },
    {
        events = { 'InsertLeave', 'WinEnter', 'VimEnter', 'BufEnter', 'BufWinEnter', 'BufNew' },
        targets = { '*' },
        command = "set cursorline"
    },
    {
        events = { 'InsertEnter', 'WinLeave' },
        targets = { '*' },
        command = "set nocursorline"
    },
    {
        events = { 'InsertEnter' },
        targets = { '*' },
        command = "set norelativenumber"
    },
    {
        events = { 'InsertLeave' },
        targets = { '*' },
        command = [[ lua if vim.g.no_number_filetypes[vim.bo.filetype] == nil then vim.o.relativenumber = true end ]]
    },
})

global_func.augroup('empty_message', {
    {
        events = { 'CursorHold' },
        targets = { '*' },
        command = ":echo "
    },

})


default_setting['opt'] = {
    guicursor = 'n-v:block-Cursor,i-ci-ve-c:ver25-Cursor', --block for normal visual mode, vertical for insert command mode. highlight set to Cursor
    relativenumber = true,
    --fillchars = "fold:-,eob: ,vert: ",          -- fillchars , fold for fold fillchars, eob for the end file begin fillchars, vert for vert split
    -- fillchars = "fold:-,eob: ,vert:▕,diff: ", -- fillchars , fold for fold fillchars, eob for the end file begin fillchars, vert for vert split
    --"│⎟⎜⎜⎢⎜▏▊▋▉▕   ref: https://unicode-table.com/en
    updatetime = 250, -- CursorHold
    undofile = true, -- use undo file
    maxmempattern = 2000, -- max match pattern
    lazyredraw = true, -- true will speed up in macro repeat

    path = vim.o.path .. ",./**",
    omnifunc = 'v:lua.vim.lsp.omnifunc', -- for default lsp
    -- conceallevel = 2,
    -- concealcursor = '', -- if set to nc, char will always fold except in insert mode
    -- foldenable=true,
    -- foldlevel = 99, -- disable fold for opened file
    -- foldminlines = 2, -- 0 means even the child is only one line, fold always works
    -- foldnestmax = 5, -- max fold nest
    -- foldmethod=marker,
    --foldexpr = "nvim_treesitter#foldexpr()",
    --completeopt = "menu,menuone,noselect",
    --t_ut = " ",                               -- disable Backgroud color Erase（BCE）
    termguicolors = true, -- TODO
    colorcolumn = "99999", -- FIXED: for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59


    compatible = false,


    switchbuf="useopen",
    -- 设置光标可以到最后一个字面后
    virtualedit="onemore",
    -- 设置快捷键等待时间
    --ttimeoutlen=80,
    -- "设置退格键为删除键
    backspace="indent,eol,start",
    -- 设置历史命令保存数
    history=10000,
    -- "关闭智能补全预览窗口
    completeopt="longest,menu",
    -- "设置自动读取外面对于文件的变更
    autoread = true,
    -- "设置命令行高度为2
    cmdheight=2,
    backup = false,
    swapfile = false,
    -- "增强模式中的命令行自动完成操作
    wildmenu = true,
    -- "开启鼠标
    mouse="a",
    -- " 启动的时候不显示那个援助索马里儿童的提示
    shortmess="atI",

     -- " 不让vim发出讨厌的滴滴声
     visualbell         = false,
     errorbells = false,
     -- "自动切换当前目录为当前文件所在目录
     autochdir = true,
     -- "默认就是全buffer搜索
     gdefault = true,
     -- "切换到当前tab打开文件的路径下
 
     -- "create undo file
     undolevels=1000,         --  " How many undos,
     undoreload=10000,        -- " number of lines to save for undo
     -- " No annoying sound on errors
     title = true,                -- " change the terminal's title
     tm=500,
     --" Remember info about open buffers on close"
 
     magic = true,
 
     -- 高亮显示匹配的括号
     showmatch = true,
     -- "中文折行不断字
     fo="tqmMB",
     --  "设置一行字数
     textwidth=80,
     -- "折行
     lbr = true,
 
     --ambiwidth="double",

     -- "开启行号显示
     number = true,
     -- "显示当前的行号列号：
     ruler = true,
     -- ""在状态栏显示正在输入的命令

     showcmd = true,
     -- " Show current mode
     showmode = true,
     -- " Set 7 lines to the cursor - when moving vertically using j/k 上下滚动,始终在中间
     scrolloff=7,
     -- " 命令行（在状态行下）的高度，默认为1，这里是2
     -- set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P
     -- " Always show the status line
     laststatus=2,
     --  " How many tenths of a second to blink when matching brackets
     mat=2,
     -- " 突出显示当前行等
     cursorline = true,
 
     -- "设置文内智能搜索提示
     -- " 高亮search命中的文本。
     hlsearch = true,
     -- " 搜索时忽略大小写
     ignorecase = true,
     -- " 在搜索时，输入的词句的逐字符高亮（类似firefox的搜索）
     incsearch = true,
     -- " 有一个或以上大写字母时仍大小写敏感
     -- " 这句千万不能要，要了命令行大小写敏感了
     -- "set smartcase     " ignore case if search pattern is all lowercase, case-sensitive otherwise
 
 
     -- " 代码折叠
     foldenable =true,
     --  " 折叠方法
     --  " manual    手工折叠
     --  " indent    使用缩进表示折叠
     --  " expr      使用表达式定义折叠
     --  " syntax    使用语法定义折叠
     --  " diff      对没有更改的文本进行折叠
     --  " marker    使用标记进行折叠, 默认标记是 {{{ 和 }}}
     foldmethod="manual",
     foldlevel=1,
 
     -- " 缩进配置
     smartindent = true, --  " Smart indent
     autoindent = true, --    " always set autoindenting on
     -- "c程序可以在v模式中按=格式化
     cin = true,
 
     -- " tab相关变更
     tabstop=4, --      " 设置Tab键的宽度        [等同的空格个数]
     shiftwidth=4 , --  " number of spaces to use for autoindenting
     softtabstop=4 , --" 按退格键时可以一次删掉 4 个空格
     smarttab   = true, --" insert tabs on the start of a line according to shiftwidth, not tabstop 按退格键时可以一次删掉 4 个空格
     expandtab     = true, -- " 将Tab自动转化成空格    [需要输入真正的Tab键时，使用 Ctrl+V + Tab]
     shiftround     = true, -- " use multiple of shiftwidth when indenting with '<' and '>'
     -- cindent shiftwidth=4,
     -- autoindent shiftwidth=4,
     listchars="tab:>-,trail:-" , -- "每行起始的tab显示为“>----”；结尾的空格显示为"-"

      -- " A buffer becomes hidden when it is abandoned
    -- " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
    hidden = true,
    autowrite = true,
    wildmode="list,full",
    -- "开启命令行忽略大小写
    wildignorecase = true,
    ttyfast = true,

    -- "设置 退出vim后，内容显示在终端屏幕, 可以用于查看和复制
    -- "好处：误删什么的，如果以前屏幕打开，可以找回
    t_ti="",
    t_te="",

    --" 设置新文件的编码为 UTF-8
    encoding="utf-8",
    -- " 自动判断编码时，依次尝试以下编码：
    fileencodings="utf-8,ucs-bom,cp936,gb18030,big5,euc-jp,euc-kr,latin1",

    -- "如果帮助无法显示中文,增加这句试试:
    helplang="cn",

    -- " 下面这句只影响普通模式 (非图形界面) 下的 Vim。
    termencoding="utf-8",

      -- " Use Unix as the standard file type
      ffs="unix,dos,mac",

    fileencodings="utf-8,chinese,latin-1",

    wildmenu = true,
    -- "set open mini-win on right or below
    -- "设置垂直分割的窗口在右边
    splitright = true,
    splitbelow = true,

    helplang="cn",
}

for key, value in pairs(default_setting['opt']) do
    vim.o[key] = value
end

for key, value in pairs(default_setting['global']) do
    vim.g[key] = value
end

vim.cmd [[
set showmatch matchtime=0 matchpairs+=<:>,《:》,（:）,【:】,“:”,‘:’
]]



--[===[

    -- 设置移动命令在行首或者行尾时依然有效 
    whichwrap={ method="append",val="b,s,<,>,[,]"},
    whichwrap={ method = "append",val = "<,>,h,l"},
    --    "设置鼠标可以选择文本
    -- selectmode={method = "append",val="mouse"},

    -- "与windows共享剪贴板
    --clipboard={method = "append",val = "pbpaste"},

    --  "打开时忽略文件名后缀
    wildignore={method = "append",val="*.o,*.obj,*.pyc,*.db,*.swp,*.bak,*.class"},

    viminfo={method = "push",val = "%"},

    -- " For regular expressions turn magic on
    -- "带有如下符号的单词不要被换行分割
    iskeyword={method="append",val = "_,$,@,%,#"},

 
    filetyle = {method="cmd",val = [[
    filetype on
    filetype indent on
    filetype plugin on
    filetype plugin indent on
    ]]},

    
  

    --"设置标记一列的背景颜色和数字一行颜色一致
    --"" for error highlight，防止错误整行标红导致看不清
    highlight = { method = "cmd", val = [[
    hi! link SignColumn   LineNr
    hi! link ShowMarksHLl DiffAdd
    hi! link ShowMarksHLu DiffChange

    highlight clear SpellBad
    highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
    highlight clear SpellCap
    highlight SpellCap term=underline cterm=underline
    highlight clear SpellRare
    highlight SpellRare term=underline cterm=underline
    highlight clear SpellLocal
    highlight SpellLocal term=underline cterm=underline
    ]] },


    -- "离开插入模式后自动关闭预览窗口
    my_pclose = { method = "cmd",val = [[
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif
    ]] },

    -- " if this not work ,make sure .viminfo is writable for you
    my_wviminfo  = {method = "cmd",val = [[
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    ]] },


    my_chdirs =  { method = "cmd",val = [[
    augroup AutoChdir
    autocmd!
    autocmd BufEnter * if &buftype !=# 'terminal' | lchdir %:p:h | endif
    augroup END
    ]] },


    --当终端支持颜色显示时打开彩色显示
    my_syntax_enable = { method= "cmd", val = [[
    if &t_Co > 1
        syntax enable
        endif
        ]] },

    


    for key,value in pairs(default_setting['opt']) do
        if type(value) == "table" then

            local method = string.lower(value['method'])
            local val = value['val']
		    local sep = value['sep'] or ','

            if(method == "append") then
                vim.o[key] = (vim.o[key] or '')  .. sep .. val
            elseif(method == "push") then
                vim.o[key] = val .. sep .. (vim.o[key] or '')
            elseif(method == "cmd") then
                vim.cmd(val)
            end

        else
            vim.o[key] = value
        end
    end

 ]===]
