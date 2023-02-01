local plugin = {}

plugin.core = {
    "marko-cerovac/material.nvim",
    as = "material",
}

plugin.mapping = function()

end

plugin.light = {

}

plugin.dark = {

}
plugin.setup = function(style)

    vim.cmd("packadd material")
    vim.g.material_style = 'palenight'
    vim.cmd 'colorscheme material'
    vim.cmd("hi clear Cursor")

    require('material').setup({
        contrast = {
            sidebars = true, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
            floating_windows = false, -- Enable contrast for floating windows
            line_numbers = false, -- Enable contrast background for line numbers
            sign_column = false, -- Enable contrast background for the sign column
            cursor_line = false, -- Enable darker background for the cursor line
            non_current_windows = false, -- Enable darker background for non-current windows
            popup_menu = false, -- Enable lighter background for the popup menu
        },

        high_visibility = {
            lighter = false, -- Enable higher contrast text for lighter style
            darker = false -- Enable higher contrast text for darker style
        },

        disable = {
            borders = true, -- Disable borders between verticaly split windows
            background = false, -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
            term_colors = false, -- Prevent the theme from setting terminal colors
            eob_lines = true -- Hide the end-of-buffer lines
        },

        lualine_style = "stealth", -- Lualine style ( can be 'stealth' or 'default' )

        custom_highlights = {
            --WinSeparator = { link = "NormalContrast" },
            DapUIValue = { link = "NormalContrast" },
            DapUIVariable = { link = "NormalContrast" },
            DapUIFrameName = { link = "NormalContrast" },
        } -- Overwrite highlights with your own
    })




    local timer = vim.loop.new_timer()
    timer:start(vim.g.after_schedule_time_start + 100, 0, vim.schedule_wrap(function()
        vim.cmd("hi! default link WhichKeyFloat Pmenu")
        --vim.cmd("hi! default link NormalFloat Pmenu")
        vim.cmd("hi! StatusLine ctermfg=black guifg=black") --set HSplit color to black
        -- FIXED: FIXED: the VertSplit is renamed to WinSeparator https://github.com/marko-cerovac/material.nvim/issues/91 ,
        vim.o.fillchars = "fold:-,eob: ,vert: ,diff: "   -- fillchars , fold for fold fillchars, eob for the end file begin fillchars, vert for vert split
        vim.cmd("hi! DiffDelete guibg=#A6647A")
    end))
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "c", "<tab>" },
        action = ":lua require('material.functions').toggle_style()<cr>",
        short_desc = "ColorStyle Exchange",
        silent = true
    })
end

return plugin
