local plugin = {}

plugin.core = 
{
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = {
                'bash',
                'c',
                'cmake',
                'cpp',
                'css',
                'diff',
                'fish',
                'gitignore',
                'go',
                'html',
                'http',
                'java',
                'javascript',
                'jsdoc',
                'jsonc',
                'latex',
                'lua',
                'markdown',
                'markdown_inline',
                'meson',
                'ninja',
                'nix',
                'norg',
                'org',
                'php',
                'python',
                'query',
                'regex',
                'rust',
                'scss',
                'sql',
                'toml',
                'tsx',
                'typescript',
                'vue',
                'wgsl',
                'yaml', -- "wgsl",
                'json',
                'groovy',
            },
            sync_install = false,
            auto_install = false,
            highlight = { enable = true },
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
reutrn plugin