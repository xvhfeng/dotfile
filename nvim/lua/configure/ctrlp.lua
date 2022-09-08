local plugin = {}

plugin.core = {
    "ctrlpvim/ctrlp.vim",
    opt_marker = "模糊查询file  oldfiles等的工具",
   opt_enable = false,


    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.cmd([[
            let g:ctrlp_working_path_mode = 'ra'
            let g:ctrlp_root_markers = ['pom.xml', '.p4ignore']
            set wildignore+=*/tmp/*,*.so,*.swp,*.zip    

            let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
            let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$',
            \ 'file': '\v\.(exe|so|dll)$',
            \ 'link': 'some_bad_symbolic_links',
            \ }

            let g:ctrlp_user_command = 'find %s -type f'   

            let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
        ]])
    end,

    config = function() -- Specifies code to run after this plugin is loaded
       
    end,

}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "s", "p" },
        action = ':CtrlP<cr>',
        short_desc = "Search Current Word",
        silent = true
    })

end
return plugin
