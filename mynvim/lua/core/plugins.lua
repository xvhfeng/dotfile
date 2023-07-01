local plugins_configure = {}

plugins_configure.plugins_groups = {}
plugins_configure.plugin_configure_root = 'plugins.'
plugins_configure["all_loaded_module"] = {}

local opt = require("util.opt")
local xlog = require("util.xlog")
local tbldump = require("util.tbldump")

xlog.trace("load plugins.lua")

plugins_configure.plugins_groups = {
    [1] = {
        ["name"] = "default",
        ["subpath"] = "",
        ["plugins"] = {
            {
                name = "material",
                enable = true,
                desc = "一个用Lua编写的快速而现代的配色方案，它支持NeoVim添加的许多新特性，如内置的LSP和TreeSitter"
            }, {name = "tokyonight", enable = false, desc = "nvim的主题"},
            {name = "vimdoc", enable = true, desc = "中文的vimdoc帮助"},
            {
                name = "auto_mkdir",
                enable = true,
                desc = "save的时候自动创建目录"
            },
            {
                name = "autojump",
                enable = true,
                desc = "集成autojump工具在vim中"
            }, {name = "FencView", enable = true, desc = "多字节支持"},
            {
                name = "genutils",
                enable = true,
                desc = "vim的工具函数集合"
            }, {
                name = "indent-blankline",
                enable = true,
                desc = "展现缩进的插件,但是只能在nvim中使用,不支持vim,可以换成支持vim的那个"
            }, {name = "rainbow", enable = true, desc = "括号颜色匹配"},
            {name = "autosession", enable = true, desc = "session保存"},
            {name = "vim-airline", enable = true, desc = "vim的状态栏"}, {
                name = "vim-emacscommandline",
                enable = true,
                desc = "vim的命令中绑定emacs按键模式"
            }, {
                name = "vim-highlight-cursor-words",
                enable = true,
                desc = "高亮当前光标下的word"
            },
            {
                name = "vim-repeat",
                enable = true,
                desc = "vim的重复命令插件"
            }, {
                name = "asynctasks",
                enable = true,
                desc = "异步执行工具,依赖于skywind3000/asyncrun.vim"
            }, {
                name = "remember",
                enable = true,
                desc = "打开文件的时候,回到上一次编辑的地方"
            },
            {
                name = "toggleterm",
                enable = true,
                desc = "虚拟终端，执行系统bash与lazydocker"
            },
            {
                name = "noice",
                enable = true,
                desc = "UI for Messgae cmdline and popupmenu"
            },
            {
                name = "preview",
                enable = true,
                desc = "预览quickfix中的结果"
            },
            {
                name = "legendary",
                enable = true,
                desc = "可以搜索的keymap function command绑定插件"
            },
            { name = "preview", enable = true, desc = "预览定义"},
            { name = "vim-fakeclip", enable = true, desc = "vim与系统之间共享clip"},
            {
                name = "which-key",
                enable = true,
                desc = "vim的操作快捷键映射"
            } --  { name="test", enable = true, desc="测试插件"},
        }
    },
    [2] = {
        ["name"] = "editor",
        ["subpath"] = "editor",
        ["plugins"] = {
            {name = "nerdcommenter", enable = true, desc = "代码注释插件"},
            {name = "textobj-word-column", enable = true, desc = "编辑多行"},
            {name = "undotree", enable = true, desc = "undo操作tree"},
            {name = "NrrwRgn", enable = true, desc = "Nrrw窗口操作选中文本区域"},
            {name = "vim-mundo", enable = true, desc = "mundo窗口操作文件变更history"},
            {
                name = "vim-expand-region",
                enable = true,
                desc = "块状编辑文本"
            },
            {
                name = "vim-surround",
                enable = true,
                desc = "快速加入修改环绕字符"
            }, {
                name = "vim-templates",
                enable = true,
                desc = "文件模版,提供c语言的h,c文件等模版功能"
            },
            {
                name = "lua-formatter",
                enable = true,
                desc = "lua-format格式化工具"
            },
            {
                name = "clang-formatter",
                enable = true,
                desc = "clang-format格式化工具"
            },
            {
                name = "whitespace",
                enable = true,
                desc = "自动删除行尾空格"
            },
            {
                name = "vim-textobj-entire",
                enable = true,
                desc = "文本对象与格式化"
            },
            {name = "editor", enable = true, desc = "编辑类key-mapping"}
        }
    },
    [3] = {
        ["name"] = "exploer",
        ["subpath"] = "exploer",
        ["plugins"] = {
            {name = "nvimtree", enable = true, desc = "lua写的floder"},
            {
                name = "bufexplorer",
                enable = true,
                desc = "buffer的资源管理器"
            }, {
                name = "maximizer",
                enable = true,
                desc = "最大化window,并且恢复原来打开的window状态"
            }, {name = "ranger", enable = true, desc = "floder管理器"},
            {
                name = "rename",
                enable = true,
                desc = "重名当前打开的文件"
            }, {
                name = "qf-helper",
                enable = true,
                desc = "一个更好的quickfix的替代品"
            }, {name = "kickfix", enable = true, desc = "filter for quickfix"},
            {
                name = "vimade",
                enable = true,
                desc = "高亮显示当前foced分割窗口"
            }, {
                name = "windowpicker",
                enable = true,
                desc = "vim分屏的时候,快速选择window"
            }, {
                name = "winresizer",
                enable = true,
                desc = "调整window的大小"
            }, {
                name = "window",
                enable = true,
                desc = "只是对于windows的key mapping的操作"
            }
        }
    },
    [4] = {
        ["name"] = "finder",
        ["subpath"] = "finder",
        ["plugins"] = {  
            { name = "spectre",  enable = true, desc = "一个搜索与替换插件" },
            {name = "fzf", enable = true, desc = "查找操作"}, {
                name = "telescope",
                enable = true,
                desc = "一个高度可扩展的列表模糊查找工具"
            },
            {
                name = "any-jump",
                enable = true,
                desc = "在定义的标记间跳转"
            }, {
                name = "preview",
                enable = true,
                desc = "预览插件"
            }, {
                name = "ssr",
                enable = true,
                desc = "使用模式替换,支持n和v两种模式"
            }, {
                name = "ferret",
                enable = true,
                desc = "使用ack或者ripgrep查找,替换字符串"
            }, {
                name = "vim-ripgrep",
                enable = true,
                desc = "使用ripgrep查询字符串"
            }
        }
    },
    [5] = {
        ["name"] = "sltdo",
        ["subpath"] = "sltdo",
        ["plugins"] = {
            {
                name = "nvim-hlslens",
                enable = true,
                desc = "高亮显示匹配信息,并且可以在匹配之间跳转,和asteris,matchup一起配合"
            },
            {name = "hop", enable = true, desc = "快速移动插件"},
            {name = "vim-bookmarks", enable = true, desc = "标记插件"},
            {name = "marks", enable = false, desc = "标记插件"},
            {
                name = "vim-unimpaired",
                enable = true,
                desc = "[ ] 开头的快捷键,vim缺失的快捷键"
            }, {
                name = "vim-asterisk",
                enable = true,
                desc = "不移动鼠标通过*/#选择文本",
                -- desc = "一个显示诊断、参考、telescope结果、快速修复和位置列表的漂亮列表，可以帮助您解决代码引起的所有问题。"
            }, {
                name = "vim-matchup",
                enable = true,
                desc = "使用%查找对应的范围标签"
            },
            {
                name = "vim-visual-multi",
                enable = true,
                desc = "多光标插件,可同时编辑选中的多出统一word"
            },
            {name = "sltdo", enable = true, desc = "navigation的key-mapping。"}
        }
    },
    [6] = {
        ["name"] = "lsp",
        ["subpath"] = "lspcfg",
        ["plugins"] = { -- 必须保证mason, mason-lspconfig,nvim-lspconfig 依次加载的顺序
            {
                name = "lsp-init",
                enable = true,
                desc = "lsp服务的配置,主要是mason,lspconfig等"
            }, -- {name = "nvim-lspfuzzy",    enable = true, desc = "查看定义等窗口" },
            {
                name = "treesitter",
                enable = true,
                desc = "Neovim的树结构和抽象层"
            }, {
                name = "lspsaga",
                enable = true,
                desc = "漂亮的lsp的窗口定义,美化LSP显示"
            }, {name = "lsp_cmp", enable = true, desc = "lsp的智能补全"},
            {name = "cmake-tools", enable = true, desc = "Cmake Tools"},
            {name = "nvim-dap", enable = true, desc = "lsp的智能补全"},
            {name = "trouble", enable = true, desc = "lsp的错误显示"},
            {name = "copilot", enable = false, desc = "GitHub的AI分析"},
            {
                name = "copilot_cmp",
                enable = false,
                desc = "GitHub的AI智能补全"
            },
            {name = "symbols-outline", enable = true, desc = "outline工具栏"}
            -- { name = "aerial",        enable = true, desc = "基于LSP的outline工具" },
            -- { name="folding-nvim", enable = true, desc="基于LSP的折叠插件"},
            -- { name = "lsp_signature", enable = true, desc = "基于LSP展现函数的签名  包括注释和参数" },
            -- { name="lspkind", enable = true, desc="这个小插件为neovim内置lsp添加了类似vcode的象形图"},
            -- { name = "navigator",     enable = true, desc = "基于LSP的源码分析和导航工具" },
            -- { name = "null-ls",       enable = true, desc = "LSP的扩展插件,可以完成诊断,格式化代码等等功能" },
            -- { name="nvim-dap", enable = true, desc="debug转换协议"},
            -- { name = "symbols-outline", enable = true, desc = "使用LSP在nvim中树状展现一个符号的outline" },
            -- { name = "vista",         enable = true, desc = "查看和搜索Vim/NeoVim中的LSP符号、标签" },
            -- {name = "ccls",enable=true,desc = "使用ccls实现智能提示,跳转tree"},
        }
    },
    [7] = {
        ["name"] = "notes",
        ["subpath"] = 'notes',
        ["plugins"] = {
            {
                name = "vimwiki",
                enable = true,
                desc = "可以非常方便地管理我们的笔记和创建代办列表，可以随时进行预览"
            }, {
                name = "calendar",
                enable = true,
                desc = "日期与todo"
            }, {
                name = "orgmode",
                enable = true,
                desc = "一个采用org格式进行记录的笔记插件，好处是写的笔记支持emacs进行编辑"
            }, {
                name = "telekasten",
                enable = true,
                desc = "用于使用基于文本的Markdown Zettelkasten/Wiki,支持与telescope 插件的整合"
            }, {
                name = "mind",
                enable = true,
                desc = "快速将笔记挂载到树上的插件，通过树将日记，笔记，wiki和任务管理等通过工作流实现"
            }
        }
    },
    [8] = {
        ["name"] = "git",
        ["subpath"] = "git",
        ["plugins"] = {
            {
                name = "tig-explorer",
                enable = true,
                desc = "git在vim中的查看"
            }, {name = "lazygit", enable = true, desc = "git的一款plugin"},
            {
                name = "diffview",
                enable = true,
                desc = "git的diff在vim中的展现"
            } -- { name="project", enable = true, desc="项目管理"},
        }
    },
    [9] = {
        ["name"] = "containers",
        ["subpath"] = "containers",
        ["plugins"] = {
            {
                name = "nvim-remote-containers",
                enable = true,
                desc = "Connect Docker"
            },
            {
                name = "vim-docker-tools",
                enable = true,
                desc = "管理docker的工具"
            },
            {
                name = "lazydocker",
                enable = true,
                desc = "管理lazydocker的UI"
            }
        }
    }
}


plugins_configure.setup = function()
    xlog.trace("myplugins's setup called")

    local lazy_plugins = {}
    -- local tbl = DataDumper(plugins_configure.plugins_groups,"plugins")
    -- print(tbl)

    local pgs = plugins_configure.plugins_groups
    xlog.trace("group count %d", #pgs)
    for gidx, plugins_group in ipairs(plugins_configure.plugins_groups) do
        local group_name = plugins_group["name"]
        local subpath = plugins_group["subpath"]
        local enable = plugins_group["enable"]
        local plugins = plugins_group["plugins"]
        local namespace = nil

        xlog.trace("group:%s enable:%s.", group_name, enable)

        if opt.isRealFalse(enable) then
            xlog.warn("group:%s enable:%s. so not load this plugin group",
                group_name, enable)
            goto continues_1
        end

        if opt.isNilOrEmpty(subpath) then
            namespace = plugins_configure.plugin_configure_root
        else
            namespace = plugins_configure.plugin_configure_root .. subpath ..
            "."
        end

        xlog.trace("group:%s plugin namespace:%s plugin count ->%d", group_name,
            namespace, #plugins)

        for idx, plugin in ipairs(plugins) do
            local plugin_name = plugin["name"]
            local plugin_enable = plugin["enable"]
            local plugin_desc = plugin["desc"]

            if opt.isRealFalse(plugin_enable) then
                xlog.warn("plugin:%s idx:%d enable:%s,so not load", plugin_name,
                    idx, plugin_enable)
                goto continue_2
            end

            xlog.trace("plugin name -> %s ,enbale ->%s desc ->%s", plugin_name,
                plugin_enable, plugin_desc)

            if nil == plugin_name then
                tbldump.tbl_trace("plugin",plugin)
            end

            local plugin_path = namespace .. plugin_name

            xlog.trace(
                "plugin:%s idx:%d [with %s] in group:%s load plugin_path:%s",
                plugin_name, idx, plugin_desc, group_name, plugin_path)

            local ok, plug = xpcall(function()
                return require(plugin_path)
            end, debug.traceback)

            if not ok then
                xlog.error("plugin:%s load failed and skip it try next one",
                    plugin_name, plugin_desc, group_name, plugin_path)
                xlog.error(plug)
                goto continue_2
            end

            local core = plug.core
            local only_keymapping = core["only_keymapping"]

            if (nil ~= only_keymapping) then
                xlog.trace(
                    "plugin:%s [with %s] in group:%s is only-keymapping(No core) loading by plugin_path:%s",
                    plugin_name, plugin_desc, group_name, plugin_path)
                plugins_configure.all_loaded_module[plugin_name] = true -- added to all_loaded_module
                goto continue_2
            end

            xlog.trace(
                "plugin:%s [with %s] in group:%s success in loading plugin_path:%s",
                plugin_name, plugin_desc, group_name, plugin_path)

            local in_enable = core["enable"]
            if opt.isRealFalse(in_enable) then
                xlog.trace(
                    "plugin:%s [with %s] in group:%s is enable=false in plugin core loading by plugin_path:%s",
                    plugin_name, plugin_desc, group_name, plugin_path)
                goto continue_2
            end

            plugins_configure.all_loaded_module[plugin_name] = true -- added to all_loaded_module
            table.insert(lazy_plugins, core) -- add to 
            ::continue_2::
        end
        xlog.info("group:%s loading over", group_name)
        xlog.blankline()
        ::continues_1::
    end

    require("lazy").setup(lazy_plugins, {
        root = vim.g.REPSPATH,
        git = {
            -- defaults for the `Lazy log` command
            -- log = { "-10" }, -- show the last 10 commits
            log = {"-8"}, -- show commits from the last 3 days
            timeout = 500, -- kill processes that take more than 2 minutes
            url_format = "https://github.com/%s.git",
            -- lazy.nvim requires git >=2.19.0. If you really want to use lazy with an older version,
            -- then set the below to false. This should work, but is NOT supported and will
            -- increase downloads a lot.
            filter = true
        },
        dev = {
            -- directory where you store your local plugin projects
            path = "~/local_plugins",
            ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
            patterns = {}, -- For example {"folke"}
            fallback = false -- Fallback to git when local plugin doesn't exist
        },
        performance = {
            cache = {enabled = true},
            reset_packpath = true, -- reset the package path to improve startup time
            rtp = {
                reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
                ---@type string[]
                paths = {vim.g.CONFIG}, -- add any custom paths here that you want to includes in the rtp
                ---@type string[] list any plugins you want to disable here
                disabled_plugins = {
                    -- "gzip",
                    -- "matchit",
                    -- "matchparen",
                    -- "netrwPlugin",
                    -- "tarPlugin",
                    -- "tohtml",
                    -- "tutor",
                    -- "zipPlugin",
                }
            }
        }

    })
end

plugins_configure.create_mapping = function()
    xlog.trace("myplugins's create_mapping called")
    local kmr = require('core.keymapping')

    xlog.trace("myplugins begin loop plugins_groups to mapping keys.")
    -- tbldump.tbl_trace("plugins_groups",plugins_configure.plugins_groups)

    for gidx, plugins_group in ipairs(plugins_configure.plugins_groups) do
        local group_name = plugins_group["name"]
        local subpath = plugins_group["subpath"]
        local enable = plugins_group["enable"]
        local plugins = plugins_group["plugins"]
        local namespace = nil

        xlog.trace("group:%s enable:%s.", group_name, enable)

        if opt.isRealFalse(enable) then
            xlog.warn("group:%s enable:%s. so not load this plugin group",
                group_name, enable)
            goto continues_1
        end

        if opt.isNilOrEmpty(subpath) then
            namespace = plugins_configure.plugin_configure_root
        else
            namespace = plugins_configure.plugin_configure_root .. subpath ..
            "."
        end

        xlog.trace("group:%s plugin namespace:%s", group_name, namespace)

        for _, plugin in ipairs(plugins) do
            local plugin_name = plugin["name"]
            local plugin_enable = plugin["enable"]
            local plugin_desc = plugin["desc"]

            if opt.isRealFalse(plugin_enable) then
                xlog.warn("plugin:%s enable:%s,so not load", plugin_name,
                    plugin_enable)
                goto continue_2
            end

            local plugin_path = namespace .. plugin_name

            xlog.trace("plugin:%s [with %s] in group:%s load plugin_path:%s",
                plugin_name, plugin_desc, group_name, plugin_path)

            -- local ok, plug = pcall(require, plugin_path)
            local ok, plug = xpcall(function()
                return require(plugin_path)
            end, debug.traceback)

            if not ok then
                xlog.error("plugin:%s load failed and skip it try next one",
                    plugin_name, plugin_desc, group_name, plugin_path)
                xlog.error(plug)
                goto continue_2
            end

            local mapping = plug["mapping"]
            local plugin_fullname = group_name .. " [ " .. plugin_name .. " ] "
            if mapping then
                if "table" == type(mapping) then 
                    kmr.mappings_parser(plugin_fullname,mapping)
                else
                    xlog.trace(plugin_fullname .. " mapping is function.execing...")
                    mapping()
                end
                --[[  
                if type({}) == type(mapping) then
                    local keys = mapping["keys"];
                    local tags = mapping["tags"]

                    if keys then
                        for _, key in pairs(keys) do
                            kmr.addkey(key)
                        end
                    end

                    if tags then
                        for _, tag in pairs(tags) do
                            kmr.addtag(tag)
                        end
                    end
                    -- key_mapping()
                    xlog.trace(
                        "plugin:%s [with %s] in group:%s success in make keymapping plugin_path:%s",
                        plugin_name, plugin_desc, group_name, plugin_path)
                else
                    mapping()
                end
                --]]
            end

            ::continue_2::
        end
        xlog.info("group:%s loading over", group_name)
        xlog.blankline()
        ::continues_1::
    end
end

return plugins_configure
