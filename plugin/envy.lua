if vim.g.loaded_envy then
  return
end
vim.g.loaded_envy = 1

vim.api.nvim_create_user_command("Envy", function()
  require("envy").open()
end, {desc = "Open envy note picker"})
