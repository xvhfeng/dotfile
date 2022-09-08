local plugin = {}

plugin.core = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    disable = false,
    opt=false,

    as = "mason-tool-installer.nvim",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require('mason-tool-installer').setup {

            -- a list of all tools you want to ensure are installed upon
            -- start; they should be the names Mason uses for each tool
            ensure_installed = {
          
              -- you can pin a tool to a particular version
              { 'golangci-lint', version = '1.47.0' },
          
              -- you can turn off/on auto_update per tool
              { 'bash-language-server', auto_update = true },
          
              'lua-language-server',
              'vim-language-server',
              'gopls',
              'stylua',
              'shellcheck',
              'editorconfig-checker',
              'gofumpt',
              'golines',
              'gomodifytags',
              'gotests',
              'impl',
              'json-to-struct',
              'luacheck',
              'misspell',
              'revive',
              'shellcheck',
              'shfmt',
              'staticcheck',
              'vint',
            },
          
            -- if set to true this will check each tool for updates. If updates
            -- are available the tool will be updated. This setting does not
            -- affect :MasonToolsUpdate or :MasonToolsInstall.
            -- Default: false
            auto_update = false,
          
            -- automatically install / update on startup. If set to false nothing
            -- will happen on startup. You can use :MasonToolsInstall or
            -- :MasonToolsUpdate to install tools and check for updates.
            -- Default: true
            run_on_start = true,
          
            -- set a delay (in ms) before the installation starts. This is only
            -- effective if run_on_start is set to true.
            -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
            -- Default: 0
            start_delay = 3000, -- 3 second delay
          }
    end,
}

plugin.mapping = function()
--[===[
    :Mason - opens a graphical status window
    :MasonInstall <package> ... - installs/reinstalls the provided packages
    :MasonUninstall <package> ... - uninstalls the provided packages
    :MasonUninstallAll - uninstalls all packages
    :MasonLog - opens the mason.nvim log file in a new tab window
--]===]
end

return plugin