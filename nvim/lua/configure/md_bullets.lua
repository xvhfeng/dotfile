local plugin = {}

plugin.core = {
    "cstsunfu/md-bullets.nvim",
    opt_marker = "org-bullets的clone代码,几乎所有的代码都是clone的,用来支持markdown",
   opt_enable = true,


    as = "md-bullets",

    ft = { "markdown", "vimwiki" },
    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.g.disable_md_bullets_padding = true
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require("md-bullets").setup {
            --symbols = { "", "", "✸", "✿", "•" }
            symbols = { " ", "##", "###", "####", "#####", "•" }
            ---- or a function that receives the defaults and returns a list
        }
        vim.cmd("hi MdHeadlineLevel1 guifg=#FFFF87 guibg=#5f5fff")
        vim.cmd("hi MdHeadlineLevel2 guifg=#00afff")
        vim.cmd("hi MdHeadlineLevel3 guifg=#00afff")
        vim.cmd("hi MdHeadlineLevel4 guifg=#00afff")
        vim.cmd("hi MdHeadlineLevel5 guifg=#00afff")
        vim.cmd("hi MdHeadlineLevel6 guifg=#a0e0e0")
    end,
}

plugin.mapping = function()
end

return plugin
