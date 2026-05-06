# envy.nvim

Yet another note-taking plugin for [neovim](https://neovim.io/).

Heavily inspired by Notational Velocity. In fact, the name is based on the grammogram
created by the letters NV (for both Notational Velocity and NeoVim). Hence, envy.

There are a number of plugins out there that offer very similar functionality, but none
of them were quite right for me.

## Dependencies

- Neovim 0.10+
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Ripgrep](https://github.com/burntsushi/ripgrep)
- [bat](https://github.com/sharkdp/bat) (optional, for syntax-highlighted previews)

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
      -- These are the defaults
      search_dirs = { "~/notes" },
      default_extension = ".md",
      sort_by_mtime = true,
      use_ignore_files = true,
      include_hidden = false,
      keymap = "<leader>nn",
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

This plugin provides a single command, `:Envy`. That command will open the note picker, where you
can search your notes. It is very much like
[Telescope's](https://github.com/nvim-telescope/telescope.nvim) `live_grep`, but (I think) a bit
more refined: the files are sorted by mtime and deduplicated, so even if a note matches multiple
lines, it'll only show up in the list once. Some may find this undesirable. It's fine for me
because if the matching line isn't the one I want, I can always open the note and search it.

You can also provide an initial query to the picker:

```vimscript
:Envy <query>
```

Alternatively, you can open the picker with the default keybinding, `<leader>nn`.

Lastly, programmatic access can be achieved by requiring the module and calling it's `open()`
function:

```lua
require("envy").open()
-- or provide an initial query
require("envy").open({ initial_query = "<query>" })
```

### Keymaps in the picker

- `<CR>`: open the selected note
- `<C-s>`: open in horizontal split
- `<C-v>`: open in vertical split
- `<C-CR>`: create a new note named for the current query

When creating a note, it will named as `<current_query><default_extension>`. For example, if
`default_extension = ".md"` (the default), and your current query is `my snacks`, you'd get a new
note in the first directory of `search_dirs` named `my snacks.md`.

See the [documentation](https://github.com/ironbars/envy.nvim/blob/main/doc/envy.txt) for full
explanation of the configuration options and keymaps.

### Tips

While this plugin only covers searching and creating notes, an additional plugin can be used to
provide links between notes. The awesome
[vimwiki](https://github.com/vimwiki/vimwiki?tab=readme-ov-file) does this well. The suggested
configuration would be as follows:

```lua
vim.g.vimwiki_list = {
  { path = "~/notes" },
  { syntax = "markdown" },
  { ext = "md" },
}
vim.g.vimwiki_global_ext = 0
```

But see vimwiki's docs to determine what the best settings would be for your use case.

Personally, vimwiki has a lot more functionality than I need, so I settled on the more minimal
[wiki.vim](https://github.com/lervag/wiki.vim).

## Alternatives (inspirations)

- The defunct [nvALT](https://github.com/ttscoff/nv) served as my primary inspiration, as it changed
  my note-taking life. When it was retired, soul-deep fear sent me on a search for a replacement.
- [FSNotes](https://fsnot.es/): an awesome replacement that replicates pretty much all of the
  functionality I wanted. However, it is only available on macOS, and I had some instability with
  it the last few updates.
- [Obsidian](https://obsidian.md/): another good replacement that happens to be cross-platform.
  It's good, but the search isn't as robust as I'd like. You can search filename, or tags, or
  content, but not all three at once.
- [notational-fzf-vim](https://github.com/alok/notational-fzf-vim): this one was really close and is
  what set me on the path of a new plugin. It works a lot like using Telescope's `live_grep`. I
  tried forking this one and tweaking it to do what I wanted, but couldn't quite get it right, as
  there was some weirdness passing options to `fzf`, which this plugin depends on.

Lastly, the one thing that all of these had in common (with the soon-to-be obvious exception of
notational-fzf-vim) was that they lacked the editing power of vim. Using vim to edit my plain text
notes is a huge upgrade for me.
