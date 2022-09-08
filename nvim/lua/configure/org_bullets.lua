local plugin = {}

plugin.core = {
    "akinsho/org-bullets.nvim",
    opt_marker = "orgmode的插件,展示unicode字符",
    opt_enable = true,

    as = "org-bullets",
    ft = { "org" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require("org-bullets").setup {
            --symbols = { "", "", "✸", "✿", "" }
            ---- or a function that receives the defaults and returns a list
            --symbols = function(default_list)
            --table.insert(default_list, "♥")
            --return default_list
            --end
            concealcursor = false, -- If false then when the cursor is on a line underlying characters are visible
                symbols = {
                  -- headlines can be a list
                  headlines = { "◉", "○", "✸", "✿" },
                  -- or a function that receives the defaults and returns a list
                  headlines = function(default_list)
                    table.insert(default_list, "♥")
                    return default_list
                  end,
                  checkboxes = {
                    half = { "", "OrgTSCheckboxHalfChecked" },
                    done = { "✓", "OrgDone" },
                    todo = { "˟", "OrgTODO" },
                  },
                }
        }
        --vim.cmd("hi OrgHeadlineLevel1 guifg=#E37FFF")
        --vim.cmd("hi OrgHeadlineLevel2 guifg=#E37FFF")
        --vim.cmd("hi OrgHeadlineLevel3 guifg=#E37FFF")
        --vim.cmd("hi OrgHeadlineLevel4 guifg=#E37FFF")
        --vim.cmd("hi OrgHeadlineLevel5 guifg=#FC6262")
        vim.cmd([===[
            syntax match OrgHeadlineStar1 /^\*\ze\s/me=e-1 conceal cchar=◉ containedin=OrgHeadlineLevel1 contained
            syntax match OrgHeadlineStar2 /^\*\{2}\ze\s/me=e-1 conceal cchar=○ containedin=OrgHeadlineLevel2 contained
            syntax match OrgHeadlineStar3 /^\*\{3}\ze\s/me=e-1 conceal cchar=✸ containedin=OrgHeadlineLevel3 contained
            syntax match OrgHeadlineStar4 /^\*{4}\ze\s/me=e-1 conceal cchar=✿ containedin=OrgHeadlineLevel4 contained
        ]===])
    end,
}

plugin.mapping = function()
end

return plugin
