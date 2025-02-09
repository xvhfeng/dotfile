local plugin = {}

plugin.core = {
    'kevinhwang91/nvim-ufo',
    dependencies = {
        'kevinhwang91/promise-async'
    },


    event = 'VeryLazy',
  
    init = function()
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.o.foldcolumn = '1' -- '0' is not bad
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end,

    config = function()
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local totalLines = vim.api.nvim_buf_line_count(0)
            local foldedLines = endLnum - lnum
            local suffix = (' 󰦸 %d %d%%'):format(foldedLines, foldedLines / totalLines * 100)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    -- str width returned from truncate() may less than 2nd argument, need padding
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            local rAlignAppndx =
                math.max(math.min(vim.opt.textwidth['_value'], width - 1) - curWidth - sufWidth, 0)
            suffix = (' '):rep(rAlignAppndx) .. suffix
            table.insert(newVirtText, { suffix, 'MoreMsg' })
            return newVirtText
        end

        opts = {
            -- INFO: Uncomment to use treeitter as fold provider, otherwise nvim lsp is used
            -- provider_selector = function(bufnr, filetype, buftype)
            --   return { "treesitter", "indent" }
            -- end,
            open_fold_hl_timeout = 400,
            close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
    
            preview = {
                win_config = {
                    border = { '', '─', '', '', '', '─', '', '' },
                    -- winhighlight = "Normal:Folded",
                    winblend = 0,
                },
                mappings = {
                    scrollU = '<C-u>',
                    scrollD = '<C-d>',
                    jumpTop = '[',
                    jumpBot = ']',
                },
            },
        }
        
        opts['fold_virt_text_handler'] = handler
        require('ufo').setup(opts)
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
        vim.keymap.set('n', 'K', function()
            local winid = require('ufo').peekFoldedLinesUnderCursor()
            if not winid then
                -- vim.lsp.buf.hover()
                vim.cmd([[ Lspsaga hover_doc ]])
            end
        end)
    end,



    --[[ 
    config = function()
        vim.o.foldcolumn = '1' -- '0' is not bad
        vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
        vim.keymap.set('n', 'zr', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zm', require('ufo').closeAllFolds)
        require('ufo').setup()
    end
 --]]
}

return plugin


--[[


小试折叠：
1  :set fdm=marker  在vim中执行该命令
2  5G  将光标跳转到第5行
3  zf10G  折叠第5行到第10行的代码，vim会在折叠的开始和结束自动添加三个连续的花括号作为标记
4  zR  打开所有折叠
5  zM  关闭所有折叠
6  zE  删除所有的折叠标签
7  退出vim窗口再次打开，执行2-6步。依然可以折叠，但是没有标记了。重新打开后折叠信息会丢失。
 
折叠方法：
1  manual  （不常用）默认折叠方法，如上面第7步即为该方法，关闭vim折叠会丢失。如果想保持折叠信息，可运行 :mkview 命令，重启后用 :loadview 命令回复。该命令生成的缓存文件位于 ~/.vim/view 文件夹中。移动或重命名文件，折叠信息依然会丢失。
2  indent  （常用）缩进折叠方法，相同的缩进中代码会被折叠。 
3  syntax  （不常用）语法高亮折叠，在c/c++中会折叠花括号部分，其它格式代码中有的不能自动折叠。 
4  marker  （常用）标记折叠方法，如上面1-6所使用的方法。关闭vim折叠信息不会丢失，而且易用控制和标注。
5  还有两种 diff 和 expr，目前我还没有用过。
 
具体介绍：
1  以 marker 为例，可以在vim中运行 :set fdm=marker 来设置折叠方法设置。折叠方法的时候，= 两边不能有空格。也可以将该命令添加到~/.vimrc中，实现vim自动加载。
2  在使用小试折叠中 2 3 步折叠的时候，vim会自动添加三个连续的花括号作为标记，可在开始的花括号前添加介绍，花括号后添加级别号，级别号不能为0。如：/*折叠介绍{{{1*/
/*}}}*/
3  级别的定义稍显复杂。在一般编码中，通常把不需要修改的代码添加标记折叠。没有必要在给折叠分等级。如果想快速折叠就切换为indent折叠方面，适用于任何有缩进的代码。
 
折叠命令：
1  zf  创建折叠，可以按照前面的方式进行折叠，也可以选中代码后进行折叠。 
2  zF  在当前行创建折叠。当一开始就计划要折叠所写代码的时候，可以用该命令创建一对折叠符号，然后再往里面填写内容。
3  :5,10fo  在vim中运行该命令会在折叠 5-10 行中的代码，可以用其它数字代替之。
4  zd  删除光标下的折叠。
5  zD  删除光标下的折叠，以及嵌套的折叠。
6  zE  删除窗口内的所有折叠。仅当 manual 和 marker 折叠方法下有效。
 
打开和关闭折叠：
1  zo  打开光标下的折叠。
2  zO  打开光标下的折叠，以及嵌套的折叠。
3  zc  关闭光标下的折叠。
4  zC  关闭光标下的折叠，以及嵌套的折叠。
5  za  当光标在关闭折叠上时，打开之。在打开折叠上时，关闭之。
6  zA  和za类似，不过对当前折叠和其嵌套折叠都有效。
7  zv  打开当前光标所在折叠，仅打开足够的折叠使光标所在的行不被折叠。
8  zr和zm  一层一层打开折叠和一层一层关闭折叠，这两个命令会递减和递增一个叫foldlevel的变量。如果你发现zm和zr不灵了，那有可能是你连续按的zr或zm次数多了，只要多按几次让foldlevel回到正常状态即可。执行以下zR和zM也可直接让foldlevel回到正常状态。
9  zR和zM  打开所有折叠，设置foldlevel为最高级别。关闭所有折叠，设置foldlevel为0。
 
在折叠间移动：
1  [z  到当前打开折叠的开始。如果已在开始处，移到包含这个折叠的折叠开始处。
2  ]z  到当前打开折叠的结束。如果已在结束处，移到包含这个折叠的折叠结束处。
3  zj  把光标移动到下一个折叠的开始处。
4  zk  把光标移动到前一个折叠的结束处。


--]]
