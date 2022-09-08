local plugin = {}

plugin.core = {
    "tpope/vim-surround",
    disable = false,
    opt=false,

    --as = "vim-surround",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}
plugin.mapping = function()

--[===[
" put ds' delete '
" put cs' ( change ' to ()
" ysiw' insert ' round word with space
" ysiwb insert () round word without space
" yss' insert ' round line
--]===]

end
return plugin
