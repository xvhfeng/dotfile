local plugin = {}

plugin.core = {
    "ekickx/clipboard-image.nvim",
    opt_marker = "图片处理插件,粘贴的时候自动插入图片的地址",
   opt_enable = false,


    cmd = { "PasteImg" },
    setup = function() -- Specifies code to run before this plugin is loaded.
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require 'clipboard-image'.setup {
            -- Default configuration for all filetype
            default = {
                img_dir = "img",
                img_name = function()
                    --return os.date('%Y-%m-%d-%H-%M-%S')

                    return vim.fn.input('Image Name: ', '') .. os.date("-%Y_%m_%d")
                end, -- Example result: "2021-04-13-10-04-18"
                affix = "![](%s)"
            },
            -- You can create configuration for ceartain filetype by creating another field (markdown, in this case)
            -- If you're uncertain what to name your field to, you can run `lua print(vim.bo.filetype)`
            -- Missing options from `markdown` field will be replaced by options from `default` field
            -- markdown = {
            -- }
        }
    end,
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<localleader>", 'p' },
        action = ":PasteImg<cr>",
        short_desc = "Paste Image"
    })
end

return plugin
