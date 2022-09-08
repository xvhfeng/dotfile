local plugin = {}

plugin.core = {
    "mg979/vim-visual-multi",
   opt_marker = "多光标选择编辑插件",
   opt_enable = true,

    --as = "vim-multiple-cursors",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}

plugin.mapping = function()

end
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

Two main modes:

in cursor mode commands work as they would in normal mode
in extend mode commands work as they would in visual mode
press Tab to switch between «cursor» and «extend» mode
Most vim commands work as expected (motions, r to replace characters, ~ to change case, etc). Additionally you can:

run macros/ex/normal commands at cursors
align cursors
transpose selections
add patterns with regex, or from visual mode
And more... of course, you can enter insert mode and autocomplete will work.

--]===]