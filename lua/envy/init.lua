local M = {}

local config = require("envy.config")
local picker = require("envy.picker")


function M.setup(user_config)
  config.setup(user_config)

  if config.options.keymap then
    vim.keymap.set("n", config.options.keymap, function()
      M.open()
    end, {desc = "Open envy note picker"})
  end
end


function M.open(opts)
  picker.open(opts or {})
end


return M
