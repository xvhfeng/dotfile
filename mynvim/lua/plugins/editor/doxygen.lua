local plugin = {}

plugin.core = {
    "vim-scripts/DoxygenToolkit.vim",
    config = function()
        vim.cmd [[
        let s:licenseTag = "Unpublished copyright. All rights reserved. This material contains\<enter>"
        let s:licenseTag = s:licenseTag . "proprietary information that should be used or copied only within\<enter>"
        let s:licenseTag = s:licenseTag . "COMPANY, except with written permission of COMPANY.\<enter>"

        if !exists("g:DoxygenToolkit_briefTag_lic_pre")
        let g:DoxygenToolkit_briefTag_lic_pre = "@brief:   "
        endif
        if !exists("g:DoxygenToolkit_briefTag_pre")
        let g:DoxygenToolkit_briefTag_pre = "@brief: "
        endif
        if !exists("g:DoxygenToolkit_fileTag")
        let g:DoxygenToolkit_fileTag = "@file:    "
        endif
        if !exists("g:DoxygenToolkit_authorTag")
        let g:DoxygenToolkit_authorTag = "@author:  "
        endif
        if !exists("g:DoxygenToolkit_dateTag")
        let g:DoxygenToolkit_dateTag = "@date:    "
        endif
        if !exists("g:DoxygenToolkit_versionTag")
        let g:DoxygenToolkit_versionTag = "@version: "
        endif

        """"""""""""""""""""""""""
        " Doxygen license comment
        """"""""""""""""""""""""""
        function! <SID>DoxygenLicenseFunc()
        call s:InitializeParameters()

        " Test authorName variable
        if !exists("g:DoxygenToolkit_companyName")
        let g:DoxygenToolkit_companyName = input("Enter name of your company: ")
        endif
        if !exists("g:DoxygenToolkit_authorName")
        let g:DoxygenToolkit_authorName = input("Enter name of the author (generally yours...) : ")
        endif
        mark d

        " Get file name
        let l:fileName = expand('%:t')
        let l:year = strftime("%Y")
        let l:copyright = "Copyright (c) "
        let l:copyright = l:copyright.l:year." ".g:DoxygenToolkit_companyName."."
        let l:license = substitute( g:DoxygenToolkit_licenseTag, "\<enter>", "\<enter>".s:interCommentBlock, "g" )
        let l:license = substitute( l:license, "COMPANY", g:DoxygenToolkit_companyName, "g" )
        exec "normal O".s:startCommentBlock
        exec "normal o".s:interCommentTag.l:copyright."\<enter>".s:interCommentTag
        exec "normal o".s:interCommentTag.l:license
        exec "normal o".s:interCommentTag.g:DoxygenToolkit_fileTag.l:fileName
        exec "normal o".s:interCommentTag.g:DoxygenToolkit_briefTag_lic_pre
        mark d
        exec "normal o".s:interCommentTag.g:DoxygenToolkit_authorTag.g:DoxygenToolkit_authorName
        exec "normal o".s:interCommentTag.g:DoxygenToolkit_versionTag."1.0"
        let l:date = strftime("%Y-%m-%d")
        exec "normal o".s:interCommentTag.g:DoxygenToolkit_dateTag.l:date
        if( s:endCommentBlock != "" )
        exec "normal o".s:endCommentBlock
        endif
        exec "normal `d"

        call s:RestoreParameters()
        startinsert!
        endfunction

        let g:DoxygenToolkit_companyName="db-exp"
        let g:DoxygenToolkit_authorName="xbgm"

        ]]
    end
}

plugin.mapping  = {
    keymaps = {
        {
            tag = { key = "<leader>ed", name = "DoxyGenTool"},
            keymaps = { 
                {
                    mode = "n",
                    key = "<leader>edh", 
                    action = "<cmd>DoxAuthor<CR>",
                    desc = "Generate Header"
                },
                {
                    mode = "n",
                    key = "<leader>edf", 
                    action = "<cmd>Dox<CR>",
                    desc = "Generate Annotation"
                },
                {
                    mode = "n",
                    key = "<leader>edl", 
                    action = "<cmd>DoxLic<CR>",
                    desc = "Generate Lic Annotation"
                },
                {
                    mode = "n",
                    key = "<leader>edb", 
                    action = "<cmd>DoxBlock<CR>",
                    desc = "Generate Block Annotation"
                },
            }
        }
    }


}

return plugin
