local plugin = {}

local function tab_win_closed(winnr)
    local api = require"nvim-tree.api"
    local tabnr = vim.api.nvim_win_get_tabpage(winnr)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local buf_info = vim.fn.getbufinfo(bufnr)[1]
    local tab_wins = vim.tbl_filter(function(w) return w~=winnr end, vim.api.nvim_tabpage_list_wins(tabnr))
    local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
    if buf_info.name:match(".*NvimTree_%d*$") then            -- close buffer was nvim tree
        -- Close all nvim tree on :q
        if not vim.tbl_isempty(tab_bufs) then                      -- and was not the last window (not closed automatically by code below)
            api.tree.close()
        end
    else                                                      -- else closed buffer was normal buffer
        if #tab_bufs == 1 then                                    -- if there is only 1 buffer left in the tab
            local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
            if last_buf_info.name:match(".*NvimTree_%d*$") then       -- and that buffer is nvim tree
                vim.schedule(function ()
                    if #vim.api.nvim_list_wins() == 1 then                -- if its the last buffer in vim
                        vim.cmd "quit"                                        -- then close all of vim
                    else                                                  -- else there are more tabs open
                        vim.api.nvim_win_close(tab_wins[1], true)             -- then close only the tab
                    end
                end)
            end
        end
    end
end

local HEIGHT_RATIO = 0.8  -- You can change this
local WIDTH_RATIO = 0.5   -- You can change this too

plugin.core = {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
        --[[
            brew tap homebrew/cask-fonts
            brew install font-hack-nerd-font
            -- choose iterm text font to font-hack-nerd-font
        --]]
        'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },

    config = function() 
        -- empty setup using defaults
        require("nvim-tree").setup({
            disable_netrw = false,
            hijack_netrw = false,
            hijack_cursor = false,
            update_cwd = false,
            sync_root_with_cwd = true,
            -- respect_buf_cwd = true,
            sort_by = "case_sensitive",
            update_focused_file = {
                enable = true,
                -- update_root = true,
            },

            actions = {
                open_file = {
                    window_picker = {
                        chars = "123456789abcdefg",
                    },
                },
            },
            view = {
                float = {
                    enable = true,
                    open_win_config = function()
                        local screen_w = vim.opt.columns:get()
                        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
                        local window_w = screen_w * WIDTH_RATIO
                        local window_h = screen_h * HEIGHT_RATIO
                        local window_w_int = math.floor(window_w)
                        local window_h_int = math.floor(window_h)
                        local center_x = (screen_w - window_w) / 2
                        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                        - vim.opt.cmdheight:get()
                        return {
                            border = 'rounded',
                            relative = 'editor',
                            row = center_y,
                            col = center_x,
                            width = window_w_int,
                            height = window_h_int,
                        }
                    end,
                },
                width = function()
                    return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
                end,
            },



        })

    end,
    init = function()

        -- close window auto when  only nvim-tree
        -- but is unuseful when lsp do something
        vim.api.nvim_create_autocmd("WinClosed", {
            callback = function ()
                local winnr = tonumber(vim.fn.expand("<amatch>"))
                vim.schedule_wrap(tab_win_closed(winnr))
            end,
            nested = true
        })

        -- workaround when using auto-session
        vim.api.nvim_create_autocmd({ 'BufEnter' }, {
            pattern = 'NvimTree*',
            callback = function()
                local api = require('nvim-tree.api')
                local view = require('nvim-tree.view')

                if not view.is_visible() then
                    api.tree.open()
                end
            end,
        })

        -- back last hidden buffer when delete a buffer
        vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
                local api = require('nvim-tree.api')

                -- Only 1 window with nvim-tree left: we probably closed a file buffer
                if #vim.api.nvim_list_wins() == 1 and api.tree.is_tree_buf() then
                    -- Required to let the close event complete. An error is thrown without this.
                    vim.defer_fn(function()
                        -- close nvim-tree: will go to the last hidden buffer used before closing
                        api.tree.toggle({find_file = true, focus = true})
                        -- re-open nivm-tree
                        api.tree.toggle({find_file = true, focus = true})
                        -- nvim-tree is still the active window. Go to the previous window.
                        vim.cmd("wincmd p")
                    end, 0)
                end
            end
        })

    end

}

function find_directory_and_focus()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function open_nvim_tree(prompt_bufnr, _)
    actions.select_default:replace(function()
      local api = require("nvim-tree.api")

      actions.close(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      api.tree.open()
      api.tree.find_file(selection.cwd .. "/" .. selection.value)
    end)
    return true
  end

  require("telescope.builtin").find_files({
    find_command = { "fd", "--type", "directory", "--hidden", "--exclude", ".git/*" },
    attach_mappings = open_nvim_tree,
  })
end

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "\\",
            action = '<cmd>NvimTreeToggle<CR>',
            desc = "Open Floder Tree",
        }, {
            tag = {key = "<leader>we", name = "Exploer"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>wet",
                    action = '<cmd>NvimTreeToggle <CR>',
                    desc = "Open Floder Tree",
                },
                {
                    mode = "n",
                    key = "<leader>wef",
                    action = ':lua find_directory_and_focus()<CR>',
                    desc = "Find&Focus File/Path",
                },

            }
        }
    }
}

return plugin




--[===[


`<C-]>`           CD                      |nvim-tree-api.tree.change_root_to_node()|
`<C-e>`           Open: In Place          |nvim-tree-api.node.open.replace_tree_buffer()|
`<C-k>`           Info                    |nvim-tree-api.node.show_info_popup()|
`<C-r>`           Rename: Omit Filename   |nvim-tree-api.fs.rename_sub()|
`<C-t>`           Open: New Tab           |nvim-tree-api.node.open.tab()|
`<C-v>`           Open: Vertical Split    |nvim-tree-api.node.open.vertical()|
`<C-x>`           Open: Horizontal Split  |nvim-tree-api.node.open.horizontal()|
`<BS>`            Close Directory         |nvim-tree-api.node.navigate.parent_close()|
`<CR>`            Open                    |nvim-tree-api.node.open.edit()|
`<Tab>`           Open Preview            |nvim-tree-api.node.open.preview()|
`>`               Next Sibling            |nvim-tree-api.node.navigate.sibling.next()|
`<`               Previous Sibling        |nvim-tree-api.node.navigate.sibling.prev()|
`.`               Run Command             |nvim-tree-api.node.run.cmd()|
`-`               Up                      |nvim-tree-api.tree.change_root_to_parent()|
`a`               Create                  |nvim-tree-api.fs.create()|
`bmv`             Move Bookmarked         |nvim-tree-api.marks.bulk.move()|
`B`               Toggle No Buffer        |nvim-tree-api.tree.toggle_no_buffer_filter()|
`c`               Copy                    |nvim-tree-api.fs.copy.node()|
`C`               Toggle Git Clean        |nvim-tree-api.tree.toggle_git_clean_filter()|
`[c`              Prev Git                |nvim-tree-api.node.navigate.git.prev()|
`]c`              Next Git                |nvim-tree-api.node.navigate.git.next()|
`d`               Delete                  |nvim-tree-api.fs.remove()|
`D`               Trash                   |nvim-tree-api.fs.trash()|
`E`               Expand All              |nvim-tree-api.tree.expand_all()|
`e`               Rename: Basename        |nvim-tree-api.fs.rename_basename()|
`]e`              Next Diagnostic         |nvim-tree-api.node.navigate.diagnostics.next()|
`[e`              Prev Diagnostic         |nvim-tree-api.node.navigate.diagnostics.prev()|
`F`               Clean Filter            |nvim-tree-api.live_filter.clear()|
`f`               Filter                  |nvim-tree-api.live_filter.start()|
`g?`              Help                    |nvim-tree-api.tree.toggle_help()|
`gy`              Copy Absolute Path      |nvim-tree-api.fs.copy.absolute_path()|
`H`               Toggle Dotfiles         |nvim-tree-api.tree.toggle_hidden_filter()|
`I`               Toggle Git Ignore       |nvim-tree-api.tree.toggle_gitignore_filter()|
`J`               Last Sibling            |nvim-tree-api.node.navigate.sibling.last()|
`K`               First Sibling           |nvim-tree-api.node.navigate.sibling.first()|
`m`               Toggle Bookmark         |nvim-tree-api.marks.toggle()|
`o`               Open                    |nvim-tree-api.node.open.edit()|
`O`               Open: No Window Picker  |nvim-tree-api.node.open.no_window_picker()|
`p`               Paste                   |nvim-tree-api.fs.paste()|
`P`               Parent Directory        |nvim-tree-api.node.navigate.parent()|
`q`               Close                   |nvim-tree-api.tree.close()|
`r`               Rename                  |nvim-tree-api.fs.rename()|
`R`               Refresh                 |nvim-tree-api.tree.reload()|
`s`               Run System              |nvim-tree-api.node.run.system()|
`S`               Search                  |nvim-tree-api.tree.search_node()|
`U`               Toggle Hidden           |nvim-tree-api.tree.toggle_custom_filter()|
`W`               Collapse                |nvim-tree-api.tree.collapse_all()|
`x`               Cut                     |nvim-tree-api.fs.cut()|
`y`               Copy Name               |nvim-tree-api.fs.copy.filename()|
`Y`               Copy Relative Path      |nvim-tree-api.fs.copy.relative_path()|
`<2-LeftMouse>`   Open                    |nvim-tree-api.node.open.edit()|
`<2-RightMouse>`  CD                      |nvim-tree-api.tree.change_root_to_node()|




--]===]
