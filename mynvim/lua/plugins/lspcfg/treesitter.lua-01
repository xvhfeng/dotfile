local plugin = {}

plugin.core = {
    "nvim-treesitter/nvim-treesitter",
--    event = "BufReadPost",
    run = ':TSUpdate',
    dependencies = {
  --      {
 --           "JoosepAlviste/nvim-ts-context-commentstring",
            --           event = "VeryLazy",
   --     },
        {
            "nvim-tree/nvim-web-devicons",
    --        event = "VeryLazy",
        },
    },
    config = function()
      -- 配置 nvim-treesitter
      require'nvim-treesitter.configs'.setup {
        -- 安装你需要的语言解析器
        ensure_installed = { "python", "lua", "cpp", "javascript", "bash" ,"sql","c"},  -- 在这里列出你需要的语言

        -- 启用语法高亮
        highlight = {
          enable = true,  -- 启用语法高亮
          disable = { "rust" },  -- 如果你不想启用某些语言的高亮，可以在这里列出
        },

        -- 启用自动缩进
        indent = {
          enable = true,
        },

        -- 启用增量选择
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",  -- 开始增量选择的快捷键
            node_incremental = "<CR>",  -- 增量选择的快捷键
            node_decremental = "<BS>",  -- 减少选择的快捷键
          },
        },

        -- 启用文本对象选择（如选中文本块）
        textobjects = {
          enable = true,
          keymaps = {
            ["af"] = "@function.outer",  -- 选择函数体的快捷键
            ["if"] = "@function.inner",  -- 选择函数内容的快捷键
            ["ac"] = "@class.outer",  -- 选择类体的快捷键
            ["ic"] = "@class.inner",  -- 选择类内容的快捷键
          },
        },
      }
    end
  }

--[[
        require "plugins/lspcfg/treesitter-setup/python"
        require('ts_context_commentstring').setup {}
        require('nvim-treesitter.configs').setup {
            ensure_installed = {
                "python",
                "vim",
                "bash",
                "c",
                "cpp",
                "lua",
                "java",
                "go",
                "jsonc",
                "json",
                "sql",
                "cmake",
                "dockerfile",
                "doxygen",
                "go",
                "make",
            },
            highlight = {
                enable = true,  -- 启用语法高亮
            },
            indent = {
                enable = true,  -- 启用缩进
            },

        }
    end,
}

--]]
return plugin
