local M = {}

local defaults = {
  search_dirs = {"~/notes"},
  default_extension = ".md",
  sort_by_mtime = true,
  use_ignore_files = true,
  include_hidden = false,
  keymap = "<leader>nn",
  path_display = "filename",
}

M.options = {}

function M.setup(user_config)
  M.options = vim.tbl_deep_extend("force", defaults, user_config or {})

  M.options.search_dirs = vim.tbl_map(function(dir)
    return vim.fn.expand(dir)
  end, M.options.search_dirs)
end

return M
