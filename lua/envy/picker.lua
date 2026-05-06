local M = {}

local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")


local search = require("envy.search")
local config = require("envy.config")


-- Format path for display
local function format_path(path, search_dirs)
  local display_mode = config.options.path_display

  local name = vim.fn.fnamemodify(path, ":t:r")

  if display_mode == "filename" then
    return name
  end

  for _, dir in ipairs(search_dirs) do
    local expanded = vim.fn.expand(dir)

    if path:sub(1, #expanded) == expanded then
      local relative = path:sub(#expanded + 2)

      if display_mode == "full" then
        return vim.fn.fnamemodify(path, ":~")
      end

      if not relative:find("/") then
        return name
      else
        local subdir = vim.fn.fnamemodify(path, ":h:t")
        return name .. "(" .. subdir .. ")"
      end
    end
  end
  
  return vim.fn.fnamemodify(path, ":t:r")
end


-- Build a display entry from search results
local function make_envy_entry(opts)
  local displayer = entry_display.create({
    separator = "",
    items = {
      {remaining = true},
    },
  })

  local function display(entry)
    local filename = format_path(entry.path, opts.search_dirs)
    local line_content = entry.text or ""

    line_content = line_content:match("^%s*(.-)%s*$")

    return displayer({
      {filename, "TelescopeResultsIdentifier"},
    })
  end

  return function(result)
    return {
      value = result,
      display = display,
      ordinal = vim.fn.fnamemodify(result.path, ":t:r") .. " " .. (result.text or ""),
      path = result.path,
      lnum = result.lnum,
    }
  end
end


function M.open(opts)
  opts = opts or {}
  local search_opts = {
    search_dirs = config.options.search_dirs,
    use_ignore_files = config.options.use_ignore_files,
    include_hidden = config.options.include_hidden,
  }
  local telescope_opts = vim.tbl_extend("force", opts, {
    default_text = opts.initial_query or ""
  })
  telescope_opts.initial_query = nil

  pickers.new(telescope_opts, {
    prompt_title = "envy",
    finder = finders.new_dynamic({
      fn = function(query)
        local results = search.search(query, search_opts)
        return results
      end,
      entry_maker = make_envy_entry({search_dirs = config.options.search_dirs})
    }),
    -- Use dummy sorter to preserve our own ordering by mtime
    sorter = require("telescope.sorters").empty(),
    previewer = conf.grep_previewer(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection then return end
        actions.close(prompt_bufnr)
        vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
        -- Jump to matching line
        if selection.lnum and selection.lnum > 1 then
          vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
          vim.cmd("normal! zz")
        end
      end)

      -- Split open
      map("i", "<C-s>", function()
        local selection = action_state.get_selected_entry()
        if not selection then return end
        actions.close(prompt_bufnr)
        vim.cmd("split " .. vim.fn.fnameescape(selection.path))
        if selection.lnum and selection.lnum > 1 then
          vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
          vim.cmd("normal! zz")
        end
      end)

      -- Vertical split
      map("i", "<C-v>", function()
        local selection = action_state.get_selected_entry()
        if not selection then return end
        actions.close(prompt_bufnr)
        vim.cmd("vsplit " .. vim.fn.fnameescape(selection.path))
        if selection.lnum and selection.lnum > 1 then
          vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
          vim.cmd("normal! zz")
        end
      end)

      -- Create new note from query
      map("i", "<C-CR>", function()
        local query = action_state.get_current_line()
        if query == "" then return end
        actions.close(prompt_bufnr)
        local new_path = config.options.search_dirs[1] .. "/" .. query .. config.options.default_extension
        vim.cmd("edit " .. vim.fn.fnameescape(new_path))
      end)

      -- Quit envy AND vim
      map("i", "<C-q>", function()
        actions.close(prompt_bufnr)
        vim.cmd("qa")
      end)

      return true
    end,
  }):find()
end

return M
