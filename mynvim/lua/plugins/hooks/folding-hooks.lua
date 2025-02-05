local plugin = {}

plugin.core = {only_hooks = true}

-- 插入折叠标记
plugin.insert_fold_marker = function()
    local filetype = vim.bo.filetype

    -- 语言和折叠标记
    local fold_start, fold_end
    if filetype == "python" or filetype == "lua" or filetype == "bash" then
        fold_start = "#region"
        fold_end = "#endregion"
    elseif filetype == "c" or filetype == "cpp" or filetype == "java" then
        fold_start = "// region"
        fold_end = "// endregion"
    else
        fold_start = "#region"
        fold_end = "#endregion"
    end

    -- 获取光标位置并插入标记
    local line = vim.fn.line(".")
    vim.fn.append(line - 1, fold_start)  -- 在光标前一行插入折叠开始标记
    vim.fn.append(line + 1, fold_end)    -- 在光标后面插入折叠结束标记
end

-- 判断当前位置是否有折叠
plugin.is_folded = function()
    local fold_start = vim.fn.foldclosed(vim.fn.line('.'))
    return fold_start ~= -1
end

-- 设置为全局函数
_G.insert_fold_marker = plugin.insert_fold_marker
_G.is_folded = plugin.is_folded

plugin.toggle_fold_or_space = function()
    local current_line = vim.fn.line('.')  -- 获取当前光标所在行
    if vim.fn.foldlevel('.') > 0 then
        vim.cmd('normal! za')  -- 如果当前行在折叠范围内，切换折叠状态
    else
        -- 如果没有折叠，执行空格键的默认行为（确保正确处理）
        -- 这里通过 `normal!` 执行空格键，直接发送空格
        vim.api.nvim_feedkeys(' ', 'n', true)
    end
end

_G.toggle_fold_or_space = plugin.toggle_fold_or_space



plugin.get_function_ranges = function()
    local parser = vim.treesitter.get_parser(0)  -- 获取当前缓冲区的 Tree-sitter 解析器
    local tree = parser:parse()  -- 解析当前缓冲区
    local root = tree[1]:root()  -- 获取语法树的根节点
    local ranges = {}  -- 存储所有函数的范围

    -- 定义一个查询语言的映射
    local queries = {
        python = [[
        (function_definition
        name: (identifier) @function
        body: (block) @body)
        ]],
        lua = [[
        (function_definition
        name: (identifier) @function
        body: (block) @body)
        ]],
        bash = [[
        (function_definition
        name: (identifier) @function
        body: (block) @body)
        ]],
        c = [[
        (function_definition
        return_type: (type) @return_type
        name: (identifier) @function
        body: (compound_statement) @body)
        ]],
        cpp = [[
        (function_definition
        return_type: (type) @return_type
        name: (identifier) @function
        body: (compound_statement) @body)
        ]],
        java = [[
        (method_declaration
        return_type: (type) @return_type
        name: (identifier) @function
        body: (block) @body)
        ]],
        go = [[
        (function_declaration
        name: (identifier) @function
        body: (block) @body)
        ]]
    }

    -- 获取当前文件类型
    local filetype = vim.bo.filetype
    if not queries[filetype] then
        return {}  -- 不支持当前语言
    end

    -- 解析当前语言的查询
    local query = vim.treesitter.query.parse(filetype, queries[filetype])

    -- 遍历语法树中的所有函数节点
    for _, node, _ in query:iter_captures(root, 0) do
        -- 获取函数的起始行和结束行
        local start_row, _, end_row, _ = node:range()
        table.insert(ranges, {start_row, end_row})
    end

    return ranges
end

plugin.add_fold_markers_to_functions_ts =  function()
    local filetype = vim.bo.filetype  -- 获取当前文件类型
    local fold_start, fold_end  -- 定义折叠标记

    -- 根据文件类型设置折叠标记
    if filetype == 'python' or filetype == 'lua' or filetype == 'bash' then
        fold_start = "#region"
        fold_end = "#endregion"
    elseif filetype == 'c' or filetype == 'cpp' or filetype == 'java' or filetype == 'go' then
        fold_start = "// region"
        fold_end = "// endregion"
    else
        return  -- 如果不支持的语言，直接返回
    end

    -- 获取所有函数的范围
    local function_ranges = plugin.get_function_ranges()

    -- 获取当前文件的所有行
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local new_lines = {}  -- 存储修改后的行
    local current_line = 0  -- 当前行的索引

    -- 遍历所有行，插入折叠标记
    for _, range in ipairs(function_ranges) do
        local start_row, end_row = range[1], range[2]

        -- 在函数开始前插入折叠开始标记
        while current_line < start_row do
            table.insert(new_lines, lines[current_line + 1])
            current_line = current_line + 1
        end
        table.insert(new_lines, fold_start)  -- 插入折叠开始标记

        -- 插入函数体（不包含折叠标记的部分）
        while current_line <= end_row do
            table.insert(new_lines, lines[current_line + 1])
            current_line = current_line + 1
        end
        table.insert(new_lines, fold_end)  -- 插入折叠结束标记
    end

    -- 将修改后的行写回缓冲区
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

_G.add_fold_markers_to_functions_ts = plugin.add_fold_markers_to_functions_ts



plugin.hooks_init = function()
    -- nvim lsp as LSP client
    -- Tell the server the capability of foldingRange,
    -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }


    local servers = require("mason-lspconfig").get_installed_servers()

    -- local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
    for _, ls in ipairs(servers) do
        require('lspconfig')[ls].setup({
            capabilities = capabilities,
            -- you can add other fields for setting up lsp server in this table
        })
    end
    require('ufo').setup()


    -- 设置折叠方法为 marker
    -- vim.o.foldmethod = 'marker'

    -- 绑定 zz 到插入标记并创建折叠
    vim.api.nvim_set_keymap('n', 'zf', ':lua insert_fold_marker()<CR>:normal! zf%<CR>', { noremap = true, silent = true })

    -- 空格键功能：如果当前位置有折叠，打开或关闭它；否则，保留原有空格行为   
    vim.api.nvim_set_keymap('n', '<Space>', ':lua toggle_fold_or_space()<CR>', { noremap = true, silent = true })

    -- 给当前文件下的所有函数，增加折叠
    vim.api.nvim_create_user_command('AddFoldMarkers', add_fold_markers_to_functions_ts, {})
end

return plugin

