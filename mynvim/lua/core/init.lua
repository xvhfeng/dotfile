local xlog = require("util.xlog")
xlog.trace("NVim Core init ...")

require('core.default')
pcall(require, "core.local") -- local maybe not exists
require('core.plugins').setup()
require('core.plugins').create_mapping()
require('core.keymapping').setup()
