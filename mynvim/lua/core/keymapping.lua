local plugin = {}

local myplugins = require('core.plugins')
local json = require("util.json")
local xlog = require("util.xlog")
-- require "util.tbl"
local tools = require "util.opt"
local tbldump = require "util.tbldump"

xlog.trace("global key mapping")
local binding_mapping = {}
local global_wkmap = {}
local global_legkeymap = {}
local global_legcmdmap = {}
local global_legfuncmap = {}
local optDef = {noremap = true, silent = true}

local mapping_prefix = {
    ["<leader>f"] = {name = "+ Find/Repalce"},
    ["<leader>b"] = {name = "+ Buffer"},
    ["<leader>c"] = {name = "+ Container"},
    ["<leader>e"] = {name = "+ Edit"},
    ["<leader>g"] = {name = "+ Git"},
    ["<leader>l"] = {name = "+ Lsp" },
    ["<leader>m"] = {name = "+ Marks"},
    ["<leader>w"] = {name = "+ Windows"},
    ["<leader>s"] = {name = "+ System"}

    --[==[ 
    ["<leader>h"] = { name = "+ History" },
    ["<leader>r"] = {name = "+ Find/Repalce"},
    ["<leader>t"] = {name = "+ Telescope"},
    ["<leader>z"] = {name = "+ Folding"},
    ["<leader>n"] = {name = "+ navigation"},
    ["<leader>j"] = { name = "+ Json/Jupyter" },
    ["<leader>l"] = { name = "+ Line" },
    ["<leader>n"] = { name = "+ New/Note" },
    ["<leader>o"] = { name = "+ Org" },
    ["<leader>p"] = { name = "+ Paste" },
    ["<leader>q"] = { name = "+ Quit/QuickFix" },
    ["<leader>r"] = { name = "+ Read" },
    ["<leader>s"] = { name = "+ Snip/Save/CtrlSF/Space/Sign" },
    ["<leader>t"] = { name = "+ Table/Terminal/Translate/Tab" },
    ["<leader>v"] = { name = "+ Visual" },
    ["<leader>w"] = { name = "+ Window" },
    ["<leader>x"] = { name = "+ Quit" },
    ["<leader>y"] = { name = "+ Yank" },
    ["<leader>1"] = { name = "+ Go buffer 1" },
    ["<leader>2"] = { name = "+ Go buffer 2" },
    ["<leader>3"] = { name = "+ Go buffer 3" },
    ["<leader>4"] = { name = "+ Go buffer 4" },
    ["<leader>5"] = { name = "+ Go buffer 5" },
    ["<leader>6"] = { name = "+ Go buffer 6" },
    ["<leader>7"] = { name = "+ Go buffer 7" },
    ["<leader>8"] = { name = "+ Go buffer 8" },
    ["<leader>9"] = { name = "+ Go buffer 9" }
    --]==]
}

--[[
     mode = "n", --string or list of string         default : "n" or {"n","v"}
     key = {"<leader>", "f"},     required
    action = "",                  required
    desc = "",                    default = short_desc
    opt = {}                    keymap's opt,default = { noremap = true, silent = true}
    cond = {}                       default = {} 
     cond value :
        --  del_first = false              default = false
            checked = false|true,default true
            target="W|whichkey" | "L|legendary" | "A|all" | "",default ""

    structre:
    mappings = {
        keymaps = {
            {
            -- name in whichkey,sort id in legendray,
            -- key = "key", --only for whichkey
            tag = {name = "",key = ""},
             keymaps = {
                { mode = "n",key = "",action = "",desc="",opt = {},cond = {}},
                }
             },
        },
        cmds = {
        },
        funcs = {
        }
    }
    --]]


local cond_parser = function(cond)
    local isWhichKey = false
    local isLegendary = false
    local isChecked = true
    local isDelFirst = false
    local target = cond["target"]
    if tools.isNilOrEmpty(target) then
        target = "a"
    end
    local low = string.lower(target)
    if 1 == string.len(low) then
        if "a" == low then
            isWhichKey = true
            isLegendary = true
        elseif "w" == low then
            isWhichKey = true
        elseif "l" == low then
            isLegendary = true
        end
    else
        if "all" == low then
            isWhichKey = true
            isLegendary = true
        elseif "whichkey" == low then
            isWhichKey = true
        elseif "legendray" == low then
            isLegendary = true
        end
    end

    local checked = cond["checked"]
    if tools.isRealFalse(checked) then
        isChecked = false
    else
        isChecked = true
    end

    local delFirst = cond["del_first"]
    if tools.isRealTrue(delFirst) then
        isDelFirst = true
    else
        isDelFirst = false
    end
    return isWhichKey, isLegendary, isChecked, isDelFirst
end

local check_binding = function(mode, map, desc)
    local isbinding = true;
    if "string" == type(mode) then
        local keystring = mode .. map
        if tools.tbl_haskey(binding_mapping, keystring) then
            local info = binding_mapping[keystring]
            isbinding = true
        else
            isbinding = false;
            binding_mapping[keystring] = desc
        end
    end
    return isbinding
end

local vim_keyset = function(isChecked, isDelFirst, mode, action, map, desc, opt)
    if isChecked then
        if "string" == type(mode) then
            if check_binding(mode, map, desc) then
                if isDelFirst then
                    vim.api.nvim_del_keymap(mode, map)
                end
            end
            if action ~= nil then
                vim.api.nvim_set_keymap(mode, map, action, opt)
            end
        end
        if "table" == type(mode) then
            for _, v in ipairs(mode) do
                if check_binding(v, map, desc) then
                    if isDelFirst then
                        vim.api.nvim_del_keymap(v, map)
                    end
                end
                if action ~= nil then
                    vim.api.nvim_set_keymap(v, map, action, opt)
                end
            end
        end
    else
        if isDelFirst then vim.api.nvim_del_keymap(mode, map) end
        if action ~= nil then
            vim.api.nvim_set_keymap(mode, map, action, opt)
        end
    end
end

local plugin_keymap_build = function(plugin_name,isWhichKey, isLegendaryKey, mode, keymap,
    action, desc, opt)
    local whichMap = {}
    local legendaryMap = {}

    if not desc then
        desc = plugin_name .."'s NoDesc"
    end

    if isWhichKey then
        xlog.trace(plugin_name .. "'s" .. keymap .." build whichkey ")
        if (("string" == type(mode) and "n" == mode) or
            ("table" == type(mode) and tools.isInArray(mode,"n"))) then
            xlog.trace(plugin_name .. "parser mode.")
            local map = {}
            table.insert(map, action)
            table.insert(map, desc)
           
            if tools.tbl_haskey(opt, 'silent') then
                map["silent"] = opt['silent']
            end
            if tools.tbl_haskey(opt, 'noremap') then
                map["noremap"] = opt['noremap']
            end
            whichMap = map
        end
    end

    if isLegendaryKey then
        xlog.trace(plugin_name .. "'s" .. keymap .." build isLegendaryKey ")
        local map = nil
        if nil == mode then
            map = {keymap, action, description = desc}
        else
            map = {keymap, action, description = desc, mode = mode}
        end
        map["opts"] = opt
        legendaryMap =  map
    end

    --- tbldump.tbl_trace(plugin_name .. "'s keymap ",whichMap,tools.__FILE__(),tools.__LINE__())
    --- tbldump.tbl_trace(plugin_name .. "'s keymap ",legendaryMap,tools.__FILE__(),tools.__LINE__())

    return whichMap, legendaryMap
end

local key_parser = function(plugin_name,keymap)
    local isWhichKey = true
    local isLegendaryKey = true
    local isChecked = true
    local isDelFirst = false

    local mode = keymap["mode"]
    local key = keymap["key"]
    local action = keymap["action"]
    local desc = keymap["desc"]
    local opt = keymap["opt"]
    local cond = keymap["cond"]

    if nil ~= cond then
        isWhichKey, isLegendaryKey, isChecked, isDelFirst = cond_parser(cond)
    end

    local optReal = tools.deepcopy(optDef)
    if tools.isNotNilAndEmptyTbl(opt) then
        for k, v in pairs(opt) do optReal[k] = v end
    end

    vim_keyset(isChecked, isDelFirst, mode, action, key, desc, optReal)

    local whichKey, legendaryKey = plugin_keymap_build(plugin_name,isWhichKey,
        isLegendaryKey, mode,
        key, action, desc, opt)

    --- tbldump.tbl_trace(plugin_name,whichKey,tools.__FILE__(),tools.__LINE__())
    --- tbldump.tbl_trace(plugin_name,legendaryKey,tools.__FILE__(),tools.__LINE__())

    return key, whichKey, legendaryKey
end

local keygroup_parser = function(plugin_name,group)
    local tag_name = nil
    local tag_key = nil

    local tag = group["tag"]
    if tools.isNotNilAndEmptyTbl(tag) then
        tag_name = tag["name"]
        tag_key = tag["key"]
    end

    xlog.trace(plugin_name .. " tag -> " .. tag_name .. " key-> " .. tag_key)

    local leggroupmaps = {}
    local wkmaps = {}
    local legmaps = {}
    local keymaps = group["keymaps"]
    ---tbldump.tbl_trace(plugin_name .. "keygroup_parser's map",keymaps)

    if tools.isNotNilAndEmptyTbl(keymaps) then
        for _, v in ipairs(keymaps) do
          ---  tbldump.tbl_trace(plugin_name .. "key_parser's keymap",v,tools.__FILE__(),tools.__LINE__())
            local keyset, wkmap, legmap = key_parser(plugin_name,v)
            if nil ~= keyset and tools.isNotNilAndEmptyTbl(wkmap) then
                wkmaps[keyset] = wkmap
            end
            if tools.isNotNilAndEmptyTbl(legmap) then
                table.insert(legmaps, legmap)
            end
        end
    end

    if tools.isNotNilAndEmptyTbl(wkmaps) then
        wkmaps[tag_key] = {name = "+" .. tag_name}
    end

    if tools.isNotNilAndEmptyTbl(legmaps) then
        leggroupmaps["itemgroup"] = tag_name
        leggroupmaps["icon"] = ''
        leggroupmaps["description"] = tag_name
        leggroupmaps["keymaps"] = legmaps
    end
    return wkmaps, leggroupmaps
end

local keymaps_parser = function(plugin_name,keymaps)
    xlog.trace(plugin_name .. "begin keymaps parser.")
    if tools.isNilOrEmptyTbl(keymaps) then return end

    --- tbldump.tbl_trace(plugin_name ,keymaps,tools.__FILE__(),tools.__LINE__())
   -- local wkmaps = {}
    -- local legmaps = {}

    
    local wkmap = {}
    local legmap = {}
    local keyset = nil
    local keymap = {}

    if tools.tbl_haskey(keymaps,"keymaps") then
        if tools.tbl_haskey(keymaps,"tag") then
            xlog.trace(plugin_name .. " keymaps have tag,it's group.")
            wkmap, legmap = keygroup_parser(plugin_name,keymaps)
           ---tbldump tbldump.tbl_trace(plugin_name ,wkmap,tools.__FILE__(),tools.__LINE__())
            --- tbldump.tbl_trace(plugin_name ,legmap,tools.__FILE__(),tools.__LINE__())
        else
            xlog.trace(plugin_name .. " keymaps have no tag,they are single keys{}.")
            for k, v in ipairs(keymaps) do
                keyset, keymap, legmap = key_parser(plugin_name,v)
                if nil ~= keyset and tools.isNotNilAndEmptyTbl(keymap) then
                    wkmap[keyset] = keymap
                end
              --- tbldump.tbl_trace(plugin_name ,wkmap,tools.__FILE__(),tools.__LINE__())
              ---  tbldump.tbl_trace(plugin_name ,legmap,tools.__FILE__(),tools.__LINE__())
            end
        end
    else 
        xlog.trace(plugin_name .. "keymaps have no inner keymaps.it maybe single key{}")
        keyset, keymap, legmap = key_parser(plugin_name,keymaps)
        if nil ~= keyset and tools.isNotNilAndEmptyTbl(keymap) then
            wkmap[keyset] = keymap
        end
       --- tbldump.tbl_trace(plugin_name ,wkmap,tools.__FILE__(),tools.__LINE__())
        --- tbldump.tbl_trace(plugin_name ,legmap,tools.__FILE__(),tools.__LINE__())
    end

    --[[ 
    if tools.isNotNilAndEmptyTbl(wkmap) then
        table.insert(wkmaps, wkmap)
    end

    if tools.isNotNilAndEmptyTbl(legmap) then
        table.insert(legmaps, legmap)
    end

    tbldump.tbl_trace(plugin_name .. "wkmaps" ,wkmaps,tools.__FILE__(),tools.__LINE__())
    tbldump.tbl_trace(plugin_name .. "legmaps" ,legmaps,tools.__FILE__(),tools.__LINE__())
    --]]
    return wkmap, legmap
end

plugin.mappings_parser = function(plugin_name,mappings)
    if tools.isNilOrEmptyTbl(mappings) then return end

      xlog.trace("begin parser mapping get from luafile for -> "..plugin_name)
      --- tbldump.tbl_trace(plugin_name,mappings,tools.__FILE__(),tools.__LINE__())

    local keymaps = mappings["keymaps"];
    local cmds = mappings["cmds"]
    local funcs = mappings["funcs"]

   -- local wkGlobalMap = {}
   -- local legGlobalMap = {}
    if tools.isNotNilAndEmptyTbl(keymaps) then
         -- xlog.trace(plugin_name .. " have keymaps.")
        for k, v in ipairs(keymaps) do
            local wkmap, legmap
            wkmap, legmap = keymaps_parser(plugin_name,v)

            if tools.isNotNilAndEmptyTbl(wkmap) then
              --- tbldump.tbl_trace("whickmap",wkmap,tools.__FILE__(),tools.__LINE__())
               table.insert(global_wkmap, wkmap)
            end
            if tools.isNotNilAndEmptyTbl(legmap) then
              ---  tbldump.tbl_trace("legendarymap",legmap,tools.__FILE__(),tools.__LINE__())
                table.insert(global_legkeymap, legmap)
            end
        end
    else
        xlog.trace(plugin_name .. "not have keymaps.")
    end

    if tools.isNotNilAndEmptyTbl(cmds) then global_legcmdmap = cmds end
    if tools.isNotNilAndEmptyTbl(funcs) then global_legfuncmap = funcs end

    ---tbldump.tbl_trace("global_wkmap",global_wkmap,tools.__FILE__(),tools.__LINE__())
    ---tbldump.tbl_trace("global_legmap",global_legkeymap,tools.__FILE__(),tools.__LINE__())


   -- tbldump.tbl_trace(plugin_name .. "'s whichkey",wkmap,tools.__FILE__(),tools.__LINE__())
   -- tbldump.tbl_trace(plugin_name .. "'s legmap ",legmap,tools.__FILE__(),tools.__LINE__())
    
   --[[  

    if tools.isNotNilAndEmptyTbl(wkGlobalMap) then
        table.insert(global_wkmap, wkGlobalMap)
    end

    if tools.isNotNilAndEmptyTbl(cmds) then global_legcmdmap = cmds end
    if tools.isNotNilAndEmptyTbl(funcs) then global_legfuncmap = funcs end
    if tools.isNotNilAndEmptyTbl(legGlobalMap) then
        table.insert(global_legkeymap, legGlobalMap)
    end

    tbldump.tbl_trace("wkGlobalMap",wkGlobalMap,tools.__FILE__(),tools.__LINE__())
    tbldump.tbl_trace("legGlobalMap",legGlobalMap,tools.__FILE__(),tools.__LINE__())


    tbldump.tbl_trace("global_wkmap",global_wkmap,tools.__FILE__(),tools.__LINE__())
    tbldump.tbl_trace("global_legmap",global_legkeymap,tools.__FILE__(),tools.__LINE__())
    --]]
end

plugin.setup = function()
    xlog.trace("global key mapping setup")

    if myplugins.all_loaded_module['which-key'] then
        -- vim.cmd("packadd which-key")

        -- log.setup("trace",log.OnlyFile,"/Users/xuhaifeng/works/nvim-log/log.log")
        --  local jstr = json.encode(mapping_prefix or {} )
        local tstr = DataDumper(mapping_prefix)
        -- print(tstr)
        --  xlog.trace("mapping prefix json\n  %s", jstr )
        xlog.trace("mapping prefix tbl\n  %s", tstr)

        -- jstr = json_encode(mapping_prefix)
        -- print(jstr)

        local wk = require("which-key")
        wk.register(mapping_prefix)
        if tools.isNotNilAndEmptyTbl(global_wkmap) then
            tbldump.tbl_trace("global_wkmap",global_wkmap,tools.__FILE__(),tools.__LINE__())
            wk.register(global_wkmap)
        end
    end

    if myplugins.all_loaded_module['legendary'] then
        local leg = require('legendary')
        if tools.isNotNilAndEmptyTbl(global_legcmdmap) then
            leg.commands(global_legcmdmap)
        end
        if tools.isNotNilAndEmptyTbl(global_legfuncmap) then
            leg.funcs(global_legfuncmap)
        end
        if tools.isNotNilAndEmptyTbl(global_legkeymap) then
            tbldump.tbl_trace("global_legmap",global_legkeymap,tools.__FILE__(),tools.__LINE__())
            leg.keymaps(global_legkeymap)
        end
    end
end

return plugin
