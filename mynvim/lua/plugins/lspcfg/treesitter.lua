local plugin = {}

plugin.core = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },

    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                "vim",
                "dockerfile",
                "doxygen",
                "make",
                'awk',
                'bash',
                'c',
                'cmake',
                'cpp',
                'css',
                'diff',
                'gitignore',
                'go',
                'html',
                'http',
                'java',
                'javascript',
                'jsdoc',
                'jsonc',
                'lua',
                'markdown',
                'markdown_inline',
                'php',
                'python',
                'query',
                'rust',
                'sql',
                'toml',
                'tsx',
                'typescript',
                'vue',
                'yaml', -- "wgsl",
                'json',
            },
            sync_install = true,
            auto_install = true,
            highlight = { 
                enable = true ,
                additional_vim_regex_highlighting = false,
            },
            rainbow = {
                enable = true,
                -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                max_file_lines = nil, -- Do not enable for files with more than n lines, int
                -- termcolors = {} -- table of colour name strings
            },
        })
    end,
}

return plugin