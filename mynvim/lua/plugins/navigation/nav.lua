local plugin = {}

plugin.core = {only_keymapping}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "["},
        action = '<c-O>',
        short_desc = "jump to better last postion"
    }, {
        mode = "n",
        key = {"<leader>", "]"},
        action = '<c-I>',
        short_desc = "jump to better new postion"
    }, {
        mode = "n",
        key = {"j"},
        action = 'gj',
        short_desc = "Treat long lines as break lines in j"
    }, {
        mode = "n",
        key = {"k"},
        action = 'gk',
        short_desc = "Treat long lines as break lines in k"
    }}
}

--[==[
"``"在跳转时会精确到列，
"''"不会回到跳转时光标所在的那一列，而是把光标放在第一个非空白字符上。

如果想回到更老的跳转位置，使用命令"CTRL-O"；与它相对应的，是"CTRL-I"，它跳转到更新的跳转位置(:help CTRL-O和:help CTRL-I)。这两个命令前面可以加数字来表示倍数。

使用命令":jumps"可以查看跳转表(:help :jumps)。    
--]==]

return plugin
