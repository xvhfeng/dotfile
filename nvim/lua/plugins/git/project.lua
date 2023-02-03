local plugin = {}

plugin.core = {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup {
            patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" ,".project"},
        }
        require('telescope').load_extension('projects')
        require'telescope'.extensions.projects.projects{}
    end
    
}

--[[

f	<c-f>	find_project_files
b	<c-b>	browse_project_files
d	<c-d>	delete_project
s	<c-s>	search_in_project_files
r	<c-r>	recent_project_files
w	<c-w>	change_working_directory

plugin.mapping = function()
    local keymap = require('core.keymapping')
    keymap.register({
        mode = {"n"},
        key = {"<leader>", "f","t" },
        action = ':NvimTreeToggle <CR>',
        short_desc = "Open Floder Tree",
    })

end

--]]
return plugin
