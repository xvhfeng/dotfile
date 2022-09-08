local plugin = {}
plugin.core = {
    "cstsunfu/vim-snippets",
   opt_marker = "各种代码的文件片段",
   opt_enable = false,

    --as = "vim-snippets",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}
plugin.mapping = function()

end
return plugin
