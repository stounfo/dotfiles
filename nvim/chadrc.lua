---@type ChadrcConfig
local M = {}

M.ui = {
  statusline = {
    theme = "vscode_colored",
  },
  theme = "catppuccin",
}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
