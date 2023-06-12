--[[
Author: your name
Date: 2023-06-12 17:39:54
LastEditTime: 2023-06-12 17:39:54
LastEditors: your name
Description: 
FilePath: /mynvim/lua/plugins/lspcfg/copilot_cmp.lua
可以输入预定的版权声明、个性签名、空行等
--]]
local plugin = {}

plugin.core = {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    init = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function ()
        require("copilot_cmp").setup({
            formatters = {
                label = require("copilot_cmp.format").format_label_text,
                --insert_text = require("copilot_cmp.format").format_insert_text,
                insert_text = require("copilot_cmp.format").remove_existing,
                preview = require("copilot_cmp.format").deindent,
            }
        })
    end
}

plugin.mapping = function()
end

return plugin
