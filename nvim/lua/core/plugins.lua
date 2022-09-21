local plugins_configure = {}

plugins_configure.plugins_groups = {}
plugins_configure.plugin_configure_root = 'plugins.'
plugins_configure["all_loaded_module"] = {}

local opt =  require("util.opt")
local xlog = require("util.xlog")
require "util.tbl"

xlog.trace("load plugins.lua")

plugins_configure.plugins_groups[1] = {
    ["name"] = "default",
    ["subpath"] = "",
    ["plugins"] = {
        { name="material", enable = true, desc="一个用Lua编写的快速而现代的配色方案，它支持NeoVim添加的许多新特性，如内置的LSP和TreeSitter"},
        { name="vimdoc", enable = true, desc="中文的vimdoc帮助"},
        -- { name="toggleterm", enable = true, desc="nvim的终端插件"},
        { name="auto_mkdir", enable = true, desc="save的时候自动创建目录"},
        { name="autojump", enable = true, desc="集成autojump工具在vim中"},
        { name="bufexplorer", enable = true, desc="buffer的资源管理器"},
        { name="context", enable = true, desc="移动文件的时候,根据代码关键字自动压缩代码段"},
        { name="FencView", enable = true, desc="多字节支持"},
        { name="genutils", enable = true, desc="vim的工具函数集合"},
        { name="indent-blankline", enable = true, desc="展现缩进的插件,但是只能在nvim中使用,不支持vim,可以换成支持vim的那个"},
        { name="LeaderF", enable = true, desc="模糊查询插件"},
        { name="leaderf-floaterm", enable = true, desc="leader与float term的结合插件"},
        { name="plenary", enable = true, desc="不需要重复写function,只适用于neovim函数"},
        { name="popup", enable = true, desc="popup在nvim中的实现"},
        { name="rainbow", enable = true, desc="括号颜色匹配"},
        { name="ranger", enable = true, desc="floder管理器"},
        { name="spectre", enable = true, desc="一个搜索与替换插件"},
        { name="telescope", enable = true, desc="一个高度可扩展的列表模糊查找工具"},
        { name="floaterm", enable = true, desc="nvim的float term插件"},
        { name="trouble", enable = true, desc="一个显示诊断、参考、telescope结果、快速修复和位置列表的漂亮列表，可以帮助您解决代码引起的所有问题。"},
        { name="undotree", enable = true, desc="undo操作tree"},
        { name="vim-airline", enable = true, desc="vim的状态栏"},
        { name="vim-emacscommandline", enable = true, desc="vim的命令中绑定emacs按键模式"},
        { name="vim-expand-region", enable = true, desc="块状编辑文本"},
        { name="vim-highlight-cursor-words", enable = true, desc="高亮当前光标下的word"},
        { name="vim-repeat", enable = true, desc="vim的重复命令插件"},
        { name="vim-surround", enable = true, desc="快速加入修改环绕字符"},
        { name="vim-trailing-whitespace", enable = true, desc="快速删除行尾空格"},
        { name="vim-unimpaired", enable = true, desc="[ ] 开头的快捷键,vim缺失的快捷键"}, 
        { name="nvim-web-devicons", enable = true, desc="nvim的web icons"},
        { name="nerdcommenter", enable = true, desc="代码注释插件"},
        { name="asynctasks", enable = true, desc="异步执行工具,依赖于skywind3000/asyncrun.vim"},
        { name="nvim-hlslens", enable = true, desc="高亮显示匹配信息,并且可以在匹配之间跳转"},
        { name="vim-easymotion", enable = true, desc="快速移动插件"},
        { name="vim-visual-multi", enable = true, desc="多光标插件,可同时编辑选中的多出统一word"},
        { name="far", enable = true, desc="查找和替换插件"},
        -- git
        { name="tig-explorer", enable = true, desc="git在vim中的查看"},
        { name="lazygit", enable = true, desc="git的一款plugin"},
        { name="diffview", enable = true, desc="git的diff在vim中的展现"},
        { name="nvim-tree", enable = true, desc="lua写的floder"},
    }
}

-- 当前卡顿,需要解决
plugins_configure.plugins_groups[2] = {
    ["name"] = "lsp",
    ["subpath"] = "lspcfg",
    ["plugins"] = {
        -- 必须保证mason, mason-lspconfig,nvim-lspconfig 依次加载的顺序
        { name="mason", enable = true, desc="第三方插件管理器"},
        { name="aerial", enable = true, desc="基于LSP的outline工具"},
        { name="folding-nvim", enable = true, desc="基于LSP的折叠插件"},
        { name="lsp_signature", enable = true, desc="基于LSP展现函数的签名  包括注释和参数"},
        { name="lspkind", enable = true, desc="这个小插件为neovim内置lsp添加了类似vcode的象形图"},
        { name="navigator", enable = true, desc="基于LSP的源码分析和导航工具"},
        { name="null-ls", enable = true, desc="LSP的扩展插件,可以完成诊断,格式化代码等等功能"},
        { name="nvim-dap", enable = true, desc="debug转换协议"},
        { name="symbols-outline", enable = true, desc="使用LSP在nvim中树状展现一个符号的outline"},
        { name="treesitter", enable = true, desc="Neovim的树结构和抽象层"},
        { name="vista", enable = true, desc="查看和搜索Vim/NeoVim中的LSP符号、标签"},
    }
}

        --[===[
        -- { name="lsp", enable = true, desc="第三方插件管理器"},
        -- { name="mason-lspconfig", enable = true, desc="mason和lspconfig的组合插件"},
        -- { name="nvim-lspconfig", enable = true, desc="lspconfig"},
        -- { name="mason-tool-installer", enable = true, desc="mason第三方插件安装工具"},
        -- { name="nvim-cmp", enable = false, desc="基于LSP的代码智能提示完成引擎"},
        -- { name="coc", enable = false, desc="代码片段和文本编辑支持,完整的LSP支持,外加额外插件加载能力"},
    }
}

--]===]
plugins_configure.plugins_groups[3] = {
    ["name"] = "notes",
    ["subpath"] = 'notes',
    ["plugins"] = {
        { name="vimwiki", enable = true, desc="可以非常方便地管理我们的笔记和创建代办列表，可以随时进行预览"},
        { name="orgmode", enable = true, desc="一个采用org格式进行记录的笔记插件，好处是写的笔记支持emacs进行编辑"},
        { name="telekasten", enable = true, desc="用于使用基于文本的Markdown Zettelkasten/Wiki,支持与telescope 插件的整合"},
        { name="mind", enable = true, desc="快速将笔记挂载到树上的插件，通过树将日记，笔记，wiki和任务管理等通过工作流实现"},
    }
}

plugins_configure.setup = function()
    xlog.trace("myplugins's setup called")
    packer.reset()
    packer.startup(function()
        xlog.trace("packer setup function is myplugins called")
        local idx = 1
        for gidx, plugins_group in ipairs(plugins_configure.plugins_groups) do
            local group_name = plugins_group["name"]
            local subpath = plugins_group["subpath"]
            local enable = plugins_group["enable"]
            local plugins = plugins_group["plugins"]
            local namespace = nil

            xlog.trace("group:%s enable:%s.",group_name, enable)

            if opt.isRealFalse(enable) then
                xlog.warn("group:%s enable:%s. so not load this plugin group",group_name, enable)
                goto continues_1
            end

            if opt.isNilOrEmpty(subpath) then
                namespace = plugins_configure.plugin_configure_root
            else
                namespace = plugins_configure.plugin_configure_root .. subpath .. "."
            end

            xlog.trace("group:%s plugin namespace:%s",group_name,namespace)

            for idx, plugin in ipairs(plugins) do
                idx = idx + 1
                local plugin_name = plugin["name"]
                local plugin_enable = plugin["enable"]
                local plugin_desc = plugin["desc"]

                if opt.isRealFalse(plugin_enable) then
                    xlog.warn("plugin:%s idx:%d enable:%s,so not load",plugin_name,idx, plugin_enable)
                    goto continue_2
                end

                local plugin_path = namespace .. plugin_name

                xlog.trace("plugin:%s idx:%d [with %s] in group:%s load plugin_path:%s",
                            plugin_name,idx, plugin_desc, group_name,plugin_path)


                local ok,plug = xpcall(function ()
                    return require(plugin_path)
                    end,debug.traceback)

                if not ok then
                    xlog.error("plugin:%s load failed and skip it try next one",
                            plugin_name,plugin_desc, group_name,plugin_path)
                    xlog.error(plug)
                    goto continue_2
                end
                --[==[
                local ok, plug = pcall(require, plugin_path)

                if not ok then
                    xlog.error("plugin:%s load failed and skip it try next one",
                            plugin_name,plugin_desc, group_name,plugin_path)
                    goto continue_2
                end
                --]==]

                local core = plug.core
                core["opt"] = false
                core["disable"] = false
                --local tbl = DataDumper(core,"core")
                --print(tbl)
                use(core)

                xlog.trace("plugin:%s [with %s] in group:%s success in loading plugin_path:%s",
                            plugin_name,plugin_desc, group_name,plugin_path)

                plugins_configure.all_loaded_module[plugin_name] = true -- added to all_loaded_module
                ::continue_2::
            end
            xlog.info("group:%s loading over",group_name)
            xlog.blankline()
            ::continues_1::
        end
    end
    )
end


plugins_configure.create_mapping = function()
    xlog.trace("myplugins's create_mapping called")
        for gidx, plugins_group in ipairs(plugins_configure.plugins_groups) do
            local group_name = plugins_group["name"]
            local subpath = plugins_group["subpath"]
            local enable = plugins_group["enable"]
            local plugins = plugins_group["plugins"]
            local namespace = nil

            xlog.trace("group:%s enable:%s.",group_name, enable)

            if opt.isRealFalse(enable) then
                xlog.warn("group:%s enable:%s. so not load this plugin group",group_name, enable)
                goto continues_1
            end

            if opt.isNilOrEmpty(subpath) then
                namespace = plugins_configure.plugin_configure_root
            else
                namespace = plugins_configure.plugin_configure_root .. subpath .. "."
            end

            xlog.trace("group:%s plugin namespace:%s",group_name,namespace)

            for idx, plugin in ipairs(plugins) do
                local plugin_name = plugin["name"]
                local plugin_enable = plugin["enable"]
                local plugin_desc = plugin["desc"]

                if opt.isRealFalse(plugin_enable) then
                    xlog.warn("plugin:%s enable:%s,so not load",plugin_name,plugin_enable)
                    goto continue_2
                end
                
                local plugin_path = namespace .. plugin_name

                xlog.trace("plugin:%s [with %s] in group:%s load plugin_path:%s",
                            plugin_name,plugin_desc, group_name,plugin_path)

                -- local ok, plug = pcall(require, plugin_path)
                local ok,plug = xpcall(function ()
                    return require(plugin_path)
                    end,debug.traceback)

                if not ok then
                    xlog.error("plugin:%s load failed and skip it try next one",
                            plugin_name,plugin_desc, group_name,plugin_path)
                    xlog.error(plug)
                    goto continue_2
                end

                local key_mapping = plug["mapping"]
                if key_mapping then 
                    key_mapping()
                    xlog.trace("plugin:%s [with %s] in group:%s success in make keymapping plugin_path:%s",
                                plugin_name,plugin_desc, group_name,plugin_path)
                end
                ::continue_2::
            end
            xlog.info("group:%s loading over",group_name)
            xlog.blankline()
            ::continues_1::
        end
end



return plugins_configure

