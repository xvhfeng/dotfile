local plugin = {}
plugin.core = {
    'mfussenegger/nvim-jdtls',

    config = function()
        require "plugins/lspcfg/inc-javalsp"
    end
}

plugin.mapping = {

}
return plugin

