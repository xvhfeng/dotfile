local plugin = {}
plugin.core = {
    "alvan/vim-indexer",
    config = function()
        vim.cmd [[
        " Project root folders, used to identify ancestor path of project root directory.
        let g:indexer_root_folders = [$HOME]

        " Project root markers, used to identify project root directory.
        let g:indexer_root_markers = ['.root','.svn','.git','.project']

        " JSON formatted configuration file which located in the project root directory,
        " makes you could specify different options for each project.
        let g:indexer_root_setting = 'indexer.json'

        " Enabled user modules.
        let g:indexer_user_modules = ['log', 'tag']

        let g:indexer_tags_watches = ["*.c", "*.h", "*.c++", "*.cpp",  "*.py"]
        let g:indexer_tags_command = "ctags"
        let g:indexer_tags_options = "-R --sort=yes --c++-kinds=+p+l --fields=+iaS --extra=+q --languages=c,c++,php,python"
        let g:indexer_tags_savedir = expand("~/.cache/tags/")
        let g:indexer_tags_handler_locate = ["locate"]
        let g:indexer_tags_handler_reload = ["reload", "-1"]
        let g:indexer_tags_handler_update = ["update"]

        ]]
    end
}

--[==[
-- input this file to project root
 > indexer.json:
 {
    "tags_watches": ["*.php"],
    "tags_command": "ctags",
    "tags_options": "-R --sort=yes --languages=php",
    "tags_savedir": "~/.vim_indexer_tags/",
    "tags_handler_locate": ["locate"],
    "tags_handler_reload": ["reload", "-1"],
    "tags_handler_update": ["update"],
 }

 then use ctrl-] to jump and Ctrl + T back
--]==]
return plugin

