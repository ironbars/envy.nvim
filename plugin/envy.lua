if vim.g.loaded_envy then
  return
end
vim.g.loaded_envy = 1

vim.api.nvim_create_user_command("Envy", function(cmd_opts)
  require("envy").open({initial_query = cmd_opts.args})
end, {desc = "Open envy note picker", nargs = "?"})
