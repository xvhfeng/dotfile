local plugin = {}

plugin.core = {

    'MattesGroeger/vim-bookmarks',
    config = function()
        vim.g.bookmark_save_per_working_dir = 1
        vim.g.bookmark_auto_save = 1

        vim.cmd [[
            "highlight BookmarkSign ctermbg=whatever ctermfg=whatever
            "highlight BookmarkAnnotationSign ctermbg=whatever ctermfg=whatever
            "highlight BookmarkLine ctermbg=whatever ctermfg=whatever
            "highlight BookmarkAnnotationLine ctermbg=whatever ctermfg=whatever

            function! g:BMWorkDirFileLocation()
            let filename = 'bookmarks'
            let location = ''
            if isdirectory('.git')
            " Current work dir is git's work tree
            let location = getcwd().'/.git'
            else
            " Look upwards (at parents) for a directory named '.git'
            let location = finddir('.git', '.;')
            endif
            if len(location) > 0
            return location.'/'.filename
            else
            return getcwd().'/.'.filename
            endif
            endfunction
            ]]
    end

}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>mm",
            action = '<cmd>BookmarkToggle<CR>',
            desc = "Toggle Mark"
        },

        {
            mode = "n",
            key = "<leader>mi",
            action = '<cmd>BookmarkAnnotate<CR>',
            desc = "Toggle Mark Annotate"
        },

        {
            tag = { key = "<leader>ml",name = "Marks"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>mla",
                    action = '<cmd>BookmarkShowAll<CR>',
                    desc = "Show All Marks"
                },
                {
                    mode = "n",
                    key = "<leader>mlc",
                    action = '<cmd>BookmarkClear<CR>',
                    desc = "Clear Current Mark"
                },
                {
                    mode = "n",
                    key = "<leader>mlk",
                    action = '<cmd>BookmarkMoveUp<CR>',
                    desc = "Move Mark Up"
                },
                {
                    mode = "n",
                    key = "<leader>mlk",
                    action = '<cmd>BookmarkMoveDown<CR>',
                    desc = "Move Mark Down"
                },
                {
                    mode = "n",
                    key = "<leader>mlp",
                    action = '<cmd>BookmarkPrev<CR>',
                    desc = "Move Mark Prev"
                },
                {
                    mode = "n",
                    key = "<leader>mln",
                    action = '<cmd>BookmarkNext<CR>',
                    desc = "Move Mark Next"
                },
            }
        }
    }
}

return plugin

--[==[

    Mappings
    The following default mappings are included<cmd>

    mx              Set mark x
    m,              Set the next available alphabetical (lowercase) mark
    m;              Toggle the next available mark at the current line
    dmx             Delete mark x
    dm-             Delete all marks on the current line
    dm<space>       Delete all marks in the current buffer
    m]              Move to next mark
    m[              Move to previous mark
    m:              Preview mark. This will prompt you for a specific mark to
        preview; press <cr> to preview the next mark.

        m[0-9]          Add a bookmark from bookmark group[0-9].
    dm[0-9]         Delete all bookmarks from bookmark group[0-9].
        m}              Move to the next bookmark having the same type as the bookmark under
the cursor. Works across buffers.
m{              Move to the previous bookmark having the same type as the bookmark under
the cursor. Works across buffers.
dm=             Delete the bookmark under the cursor.
Set default_mappings = false in the setup function if you don't want to have these mapped.

You can change the keybindings by setting the mapping table in the setup function<cmd>


require'marks'.setup {
  mappings = {
    set_next = "m,",
    next = "m]",
    preview = "m<cmd>",
    set_bookmark0 = "m0",
    prev = false -- pass false to disable only this default mapping
  }
}
The following keys are available to be passed to the mapping table<cmd>

  set_next               Set next available lowercase mark at cursor.
  toggle                 Toggle next available mark at cursor.
  delete_line            Deletes all marks on current line.
  delete_buf             Deletes all marks in current buffer.
  next                   Goes to next mark in buffer.
  prev                   Goes to previous mark in buffer.
  preview                Previews mark (will wait for user input). press <cr> to just preview the next mark.
  set                    Sets a letter mark (will wait for input).
  delete                 Delete a letter mark (will wait for input).

  set_bookmark[0-9]      Sets a bookmark from group[0-9].
  delete_bookmark[0-9]   Deletes all bookmarks from group[0-9].
  delete_bookmark        Deletes the bookmark under the cursor.
  next_bookmark          Moves to the next bookmark having the same type as the
                         bookmark under the cursor.
  prev_bookmark          Moves to the previous bookmark having the same type as the
                         bookmark under the cursor.
  next_bookmark[0-9]     Moves to the next bookmark of of the same group type. Works by
                         first going according to line number, and then according to buffer
                         number.
  prev_bookmark[0-9]     Moves to the previous bookmark of of the same group type. Works by
                         first going according to line number, and then according to buffer
                         number.
  annotate               Prompts the user for a virtual line annotation that is then placed
                         above the bookmark. Requires neovim 0.6+ and is not mapped by default.
marks.nvim also provides a list of <Plug> mappings for you, in case you want to map things via vimscript. The list of provided mappings are<cmd>

<Plug>(Marks-set)
<Plug>(Marks-setnext)
<Plug>(Marks-toggle)
<Plug>(Marks-delete)
<Plug>(Marks-deleteline)
<Plug>(Marks-deletebuf)
<Plug>(Marks-preview)
<Plug>(Marks-next)
<Plug>(Marks-prev)

<Plug>(Marks-delete-bookmark)
<Plug>(Marks-next-bookmark)
<Plug>(Marks-prev-bookmark)
<Plug>(Marks-set-bookmark[0-9])
<Plug>(Marks-delete-bookmark[0-9])
<Plug>(Marks-next-bookmark[0-9])
<Plug>(Marks-prev-bookmark[0-9])
See <cmd>help marks-mappings for more information.

Highlights and Commands
marks.nvim defines the following highlight groups<cmd>

MarkSignHL The highlight group for displayed mark signs.

MarkSignNumHL The highlight group for the number line in a signcolumn.

MarkVirtTextHL The highlight group for bookmark virtual text annotations.

marks.nvim also defines the following commands<cmd>

<cmd>MarksToggleSigns[ buffer] Toggle signs globally. Also accepts an optional buffer number to toggle signs for that buffer only.

<cmd>MarksListBuf Fill the location list with all marks in the current buffer.

<cmd>MarksListGlobal Fill the location list with all global marks in open buffers.

<cmd>MarksListAll Fill the location list with all marks in all open buffers.

<cmd>BookmarksList group_number Fill the location list with all bookmarks of group "group_number".

<cmd>BookmarksListAll Fill the location list with all bookmarks, across all groups.

There are also corresponding commands for those who prefer the quickfix list<cmd>

<cmd>MarksQFListBuf

<cmd>MarksQFListGlobal

<cmd>MarksQFListAll

<cmd>BookmarksQFList group_number

<cmd>BookmarksQFListAll

--]==]
