# envy.nvim

Yet another note-taking plugin for [neovim](https://neovim.io/).

Heavily inspired by Notational Velocity.  In fact, the name is based on the grammogram
created by the letters NV (for both Notational Velocity and NeoVim).  Hence, envy.

There are a number of plugins out there that offer very similar functionality, but none
of them were quite right for me.  

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim), add a plugin spec like this:

```lua
{
  "ironbars/envy.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("envy").setup({
      -- No need to set these directly; these are the defaults
      search_dirs = { "~/notes" },
      keymap = "<leader>en",
      path_display = "filename",
    })
  end,
}
```
  
Using [vim-plug](https://github.com/junegunn/vim-plug):

```vimscript
Plug 'ironbars/envy.nvim'
```

## Usage

TODO
