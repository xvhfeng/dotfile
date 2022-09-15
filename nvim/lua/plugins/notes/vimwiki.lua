local plugin = {}

plugin.core = {
    'vimwiki/vimwiki',

    vim.cmd[[
    let g:vimwiki_list = [{'path': '~/vimwiki/',
    \ 'syntax': 'markdown', 'ext': '.md'}]
    ]]
}

plugin.mapping = function()

end

return plugin

--[===[ 
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
