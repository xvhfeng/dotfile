local M = {}

local Terminal = require("toggleterm.terminal").Terminal

-- Docker
local docker_tui = "lazydocker"

local docker_client = Terminal:new {
  cmd = docker_tui,
  hidden = true,
  direction = "float",
}

function M.toggle()
  docker_client:toggle()
end

return M
