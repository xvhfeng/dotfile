vim.opt.runtimepath:prepend(vim.fn.getcwd())

local messages = require("core.messages")
messages.setup()

local buffer = messages.buffer()
assert(vim.api.nvim_buf_is_valid(buffer), "message buffer was not created")
assert(vim.api.nvim_buf_get_name(buffer):match("%*Neovim%-Messages%*$"), "wrong message buffer name")
assert(vim.bo[buffer].buftype == "nofile", "message buffer must be nofile")
assert(vim.bo[buffer].bufhidden == "hide", "message buffer must be hidden")
assert(vim.bo[buffer].swapfile == false, "message buffer must not use a swapfile")

messages.setup()
assert(messages.buffer() == buffer, "setup must reuse its message buffer")

vim.notify("notify marker", vim.log.levels.ERROR)
print("print marker")
vim.api.nvim_echo({ { "echo marker", "WarningMsg" } }, true, {})

local text = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
assert(text:find("[ERROR] notify marker", 1, true), "notify message was not recorded")
assert(text:find("[PRINT] print marker", 1, true), "print message was not recorded")
assert(text:find("[ECHO] echo marker", 1, true), "echo message was not recorded")

assert(vim.fn.exists(":OpenMessages") == 2, "OpenMessages command is missing")
assert(vim.fn.exists(":ClearMessages") == 2, "ClearMessages command is missing")
assert(vim.fn.exists(":MessagesKeylogToggle") == 2, "MessagesKeylogToggle command is missing")

vim.cmd("OpenMessages")
assert(vim.api.nvim_get_current_buf() == buffer, "OpenMessages did not display the message buffer")
vim.cmd("ClearMessages")
assert(table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n") == "", "ClearMessages did not empty the buffer")
