local global_mapping = {}

local used = {
    n = {}, --Normal
    v = {}, -- Visual and Select
    i = {}, -- Insert
    c = {}, -- Command-line
    s = {}, -- Select
    o = {}, -- Operator-pending
    l = {}, -- ":lmap" mappings for Insert, Command-line and Lang-Arg
    x = {}, -- Visual
    ["!"] = {}, -- Insert and Command-line
    t = {}, -- Terminal
    [""] = {} -- map
}
local myplugins = require('core.plugins')


local json = require("util.json")
local tbl = require("util.tbl")

local mapping_prefix = {
    ["<leader>f"] = { name = "+ File Exploer" },
    ["<leader>b"] = { name = "+ Buffer" },
    ["<leader>c"] = { name = "+ Comment" },
    ["<leader>e"] = { name = "+ Edit" },
    ["<leader>g"] = { name = "+ Git"},
    ["<leader>m"] = { name = "+ Marks" },
    ["<leader>n"] = { name = "+ navigation" },
    ["<leader>r"] = { name = "+ Find/Repalce" },
    ["<leader>t"] = { name = "+ Telescope" },
    ["<leader>z"] = { name = "+ Folding" },
    ["<leader>w"] = { name = "+ Windows" },



    --[==[ 
    ["<leader>h"] = { name = "+ History" },
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


global_mapping.register = function(new_map)
    --  mode = "n", --string or list of string         default : "n" or {"n"}
    --  key = {"<leader>", "f"},     required
    --  noremap = nil,               default : nil
    --  action = "",                  required
    --  short_desc = "",              default : No DESC
    --  desc = "",                    default = short_desc
    --  expr = nil,                   default = nil
    --  silent = nil,                 default = nil
    --  del_first = false              default = false

    -- default
    if new_map['mode'] == nil then
        new_map['mode'] = 'n'
    end

    -- 一键多mode的情况下,多次注册
    if type(new_map['mode']) == "table" then
        local map_list = new_map['mode']
        for i, val in ipairs(new_map['mode']) do
            new_map['mode'] = val
            if val == nil then
                print("The mode list is not support nil.")
            end
            global_mapping.register(new_map)
        end
        return
    end
    if new_map['short_desc'] == nil then
        new_map['short_desc'] = "NO DESC"
    end
    if new_map['desc'] == nil then
        new_map['desc'] = "NO DESC"
    end

    local option = {}
    if new_map['noremap'] ~= nil then
        option['noremap'] = new_map.noremap
    end
    if new_map['expr'] ~= nil then
        option['expr'] = new_map['expr']
    end
    if new_map['silent'] ~= nil then
        option['silent'] = new_map['silent']
    end

    local del_first = false
    if new_map['del_first'] ~= nil then
        del_first = new_map['del_first']
    end

    local uni_key_string = ""
    local key_list = {}

    -- 将key的序列排列成字符串形式,并且加入keylist
    -- keylist = { { <leader> , k1, k2, k3.... } , { <localleader> , k1, k2, k3.... },{  k1, k2, k3.... }  }
    for _, key in pairs(new_map.key) do
        if key == "<leader>" then
            uni_key_string = uni_key_string .. vim.g.mapleader
        elseif key == "<localleader>" then
            uni_key_string = uni_key_string .. vim.g.maplocalleader
        else
            uni_key_string = uni_key_string .. key
        end
        if key == vim.g.mapleader then
            table.insert(key_list, "<leader>")
        elseif key == vim.g.maplocalleader then
            table.insert(key_list, "<localleader>")
        else
            table.insert(key_list, key)
        end
    end

    -- 检测key的冲突性
    if used[new_map['mode']][uni_key_string] then
        print("Mode " .. new_map['mode'] .. " " .. uni_key_string .. " has been used for " .. used[new_map['mode']][uni_key_string] .. ", you should change " .. new_map["short_desc"] .. " to another one.")
        return
    else
        used[new_map['mode']][uni_key_string] = new_map['short_desc']
    end
    if myplugins.all_loaded_module['which_key'] and #key_list > 1 and new_map.mode == 'n' then
        local prefix = key_list[1]
        if #key_list > 1 then
            prefix = prefix .. key_list[2]
        end
        local tail = ""
        for i = 3, #key_list, 1 do
            tail = tail .. key_list[i]
        end
        -- key 拆成 prefix= k1..k2,tail = k3..k4......
        if mapping_prefix[prefix] == nil then
            mapping_prefix[prefix] = {}
            mapping_prefix[prefix]['name'] = new_map['short_desc']
        end
        if tail ~= "" then
            mapping_prefix[prefix][tail] = { new_map.action, new_map.short_desc }
        else
            mapping_prefix[prefix] = { new_map.action, new_map.short_desc }
        end
        if new_map['silent'] ~= nil then
            if tail ~= "" then
                mapping_prefix[prefix][tail]['silent'] = new_map['silent']
            else
                mapping_prefix[prefix]['silent'] = new_map['silent']
            end
        end
        if new_map['noremap'] ~= nil then
            if tail ~= "" then
                mapping_prefix[prefix][tail]['noremap'] = new_map['noremap']
            else
                mapping_prefix[prefix]['noremap'] = new_map['noremap']
            end
        end
    else
        if new_map.action ~= nil then
            if del_first then
                print(uni_key_string)
                vim.api.nvim_del_keymap(new_map.mode,uni_key_string)
            end
            vim.api.nvim_set_keymap(new_map.mode, uni_key_string, new_map.action, option)
        end
    end

end

global_mapping.register({
    mode = "i",
    key = { vim.g.mapleader },
    action = vim.g.mapleader,
})

global_mapping.register({
    mode = "i",
    key = { vim.g.maplocalleader },
    action = vim.g.maplocalleader,
})

-- common mappings
global_mapping.register({
    mode = "t",
    key = { "<esc>" },
    action = "<C-\\><C-n>",
})

global_mapping.register({
    mode = "i",
    key = { "k", "j" },
    action = "<esc>",
    short_desc = "ESC"
})

global_mapping.register({
    mode = "c",
    key = { "k", "j" },
    action = "<esc>",
    short_desc = "ESC"
})
global_mapping.register({
    mode = "t",
    key = { "k", "j" },
    action = "<esc>",
    short_desc = "ESC"
})



--[==[ 
global_mapping.register({
    mode = "n",
    key = { "t" },
    action = '<esc>o<esc>',
    short_desc = "New Spaceline under"
})

global_mapping.register({
    mode = "n",
    key = { "T" },
    action = '<esc>O<esc>',
    short_desc = "New Spaceline up"
})
--]==]

global_mapping.register({
    mode = "n",
    key = {"j"},
    action = 'gj',
    short_desc = "Treat long lines as break lines in j"
})

global_mapping.register({
    mode = "n",
    key = {"k"},
    action = 'gk',
    short_desc = "Treat long lines as break lines in k"
})

--[==[
global_mapping.register({
    mode = "n",
    key = {"K"},
    action = 'i<cr><esc>',
    short_desc = "insert new line symbols"
})
--]==]
-- x exit, exec





--[===[
zc	关闭当前打开的折叠
zo	打开当前的折叠
zm	关闭所有折叠
zM	关闭所有折叠及其嵌套的折叠
zr	打开所有折叠
zR	打开所有折叠及其嵌套的折叠
zd	删除当前折叠
zE	删除所有折叠
zj	移动至下一个折叠
zk	移动至上一个折叠

zn	禁用折叠
zN	启用折叠

--]===]
global_mapping.register({
    mode = "n",
    key = { "z", "f" },
    action = 'zf%',
    short_desc = "folding"
})

global_mapping.register({
    mode = "n",
    key = {"<SPACE>"},
    action = 'za',
    short_desc = "toggle folding"
})


global_mapping.register({
    mode = "n",
    key = { "<leader>", "[" },
    action = '<c-O>',
    short_desc = "jump to better last postion"
})

global_mapping.register({
    mode = "n",
    key = { "<leader>", "]" },
    action = '<c-I>',
    short_desc = "jump to better new postion"
})

--[==[
"``"在跳转时会精确到列，
"''"不会回到跳转时光标所在的那一列，而是把光标放在第一个非空白字符上。

如果想回到更老的跳转位置，使用命令"CTRL-O"；与它相对应的，是"CTRL-I"，它跳转到更新的跳转位置(:help CTRL-O和:help CTRL-I)。这两个命令前面可以加数字来表示倍数。

使用命令":jumps"可以查看跳转表(:help :jumps)。    
--]==]

global_mapping.setup = function()
    if myplugins.all_loaded_module['indent-blankline'] ~= nil then
        global_mapping.register({
            mode = "n",
            key = { "<leader>", "<TAB>" },
            action = "za:IndentBlanklineRefresh<CR>",
            short_desc = "Smart toggle fold",
            silent = true
        })
    else
        global_mapping.register({
            mode = "n",
            key = { "<leader>", "<TAB>" },
            action = "@=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>",
            short_desc = "Smart toggle fold",
            silent = true
        })
    end

    vim.cmd([[
    inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<tab>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
    ]])
    if myplugins.all_loaded_module['which-key'] then
        -- vim.cmd("packadd which-key")
        local wk = require("which-key")
        wk.register(mapping_prefix)
    end


end

global_mapping.add_mapping_prefix = function(name,prefix)
    mapping_prefix[name] = prefix
end

return global_mapping


