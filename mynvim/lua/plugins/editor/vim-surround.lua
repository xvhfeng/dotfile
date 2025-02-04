local plugin = {}

--    Old text                    Command         New text
----------------------------------------------------------------------------------
--    surr*ound_words             ysiw)           (surround_words)
--    *make strings               ys$"            "make strings"
--    [delete ar*ound me!]        ds]             delete around me!
--    remove <b>HTML t*ags</b>    dst             remove HTML tags
--    'change quot*es'            cs'"            "change quotes"
--    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
--    delete(functi*on calls)     dsf             function calls

plugin.core = {
    "tpope/vim-surround",
}
--[===[
" put ds' delete '
" put cs' ( change ' to ()
" ysiw' insert ' round word with space
" ysiwb insert () round word without space
" yss' insert ' round line
--]===]

return plugin
