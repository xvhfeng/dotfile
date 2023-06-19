local plugin = {}

plugin.core = {
    'vimwiki/vimwiki',
    config = function()
        vim.g.vimwiki_list = "[{'path': '~/notes/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]"
    end
}

return plugin

--[===[ 
[count]ww打开第[count]个wiki索引文件
[count]wt在新标签页中打开第 [count]个wiki索引文件
ws列出可选择的wiki列表
[count]wi打开第[count]个wiki项目的日记首页
[count]ww打开今天第[count]个wiki日记文件
[count]wt在新标签页中打开今天第[count]个wiki日记文件
<Leader>wh转换当前wiki页面为HTML
<Leader>whh转换当前wiki页面为HTML并在浏览器中打开
<Cr>进入（必要时创建新的）wiki词条
<Backspace>回到上一个wiki词条
<Tab>寻找并将光标定位到本页的下一个wiki词条
<Leader>wd删除光标所在的wiki词条

Basic key bindings
<Leader>ww -- Open default wiki index file.
<Leader>wt -- Open default wiki index file in a new tab.
<Leader>ws -- Select and open wiki index file.
<Leader>wd -- Delete wiki file you are in.
<Leader>wr -- Rename wiki file you are in.
<Enter> -- Follow/Create wiki link.
<Shift-Enter> -- Split and follow/create wiki link.
<Ctrl-Enter> -- Vertical split and follow/create wiki link.
<Backspace> -- Go back to parent(previous) wiki link.
<Tab> -- Find next wiki link.
<Shift-Tab> -- Find previous wiki link.
Advanced key bindings
Refer to the complete documentation at :h vimwiki-mappings to see many more bindings.

Commands
:Vimwiki2HTML -- Convert current wiki link to HTML.
:VimwikiAll2HTML -- Convert all your wiki links to HTML.
:help vimwiki-commands -- List all commands.
:help vimwiki -- General vimwiki help docs.
--]===]
