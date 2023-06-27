
local plugin = {}

plugin.core = {
    "mg979/vim-visual-multi",
    dependencies = {
        {
            "Shougo/deoplete.nvim"
        },
    },
    config = function()
        vim.cmd([[
            aug VMlens
            au!
            au User visual_multi_start lua require('vvm-hls-inc').start()
            au User visual_multi_exit lua require('vvm-hls-inc').exit()
            aug END
            ]])
    end
}

return plugin

--[===[
It's called vim-visual-multi in analogy with visual-block, but the plugin works mostly from normal mode.

Basic usage:

select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
create cursors vertically with Ctrl-Down/Ctrl-Up
select one character at a time with Shift-Arrows
press n/N to get next/previous occurrence
press [/] to select next/previous cursor
press q to skip current and get next occurrence
press Q to remove current cursor/selection
start insert mode with i,a,I,A


Find Next               n         find next occurrence
Find Prev               N         find previous occurrence
Goto Next               ]         go to next selected region
Goto Prev               [         go to previous selected region
Seek Next             <C-f>       fast go to next (from next page)
Seek Prev             <C-b>       fast go to previous (from previous page)
Skip Region             q         skip and find to next
Remove Region           Q         remove region under cursor
Slash Search            g/        extend/move cursors with /
Replace                 R         replace in regions, or start replace mode
Toggle Multiline        M         see |vm-multiline-mode|


--]===]
