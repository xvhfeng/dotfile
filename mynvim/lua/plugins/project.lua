local plugin = {}

plugin.core = {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup {
          -- 自动启用手动模式，只有在没有找到 .git 等目录时才启用
             manual_mode = true,
          --
          --     -- 设置默认的工作目录（Neovim 启动时的目录）
           detection_methods = { "pattern", "lsp" },
            patterns = { ".git", ".hg", ".svn", ".project", ".root"},
        }
        -- require('telescope').load_extension('projects')
        -- require'telescope'.extensions.projects.projects{}
    end

}

--[[

f   <c-f>   find_project_files
b   <c-b>   browse_project_files
d   <c-d>   delete_project
s   <c-s>   search_in_project_files
r   <c-r>   recent_project_files
w   <c-w>   change_working_directory


--]]
return plugin
