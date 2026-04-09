local M = {}


local function get_mtime(filepath)
  local stat = vim.uv.fs_stat(filepath)
  return stat and stat.mtime.sec or 0
end


-- Get all files in a directory using rg, sorted by mtime
local function list_files(search_dirs, use_ignore_files, include_hidden)
  local args = {"rg", "--files"}

  if not use_ignore_files then
    table.insert(args, "--no-ignore")
  end

  if not include_hidden then
    table.insert(args, "--hidden")
  end

  for _, dir in ipairs(search_dirs) do
    table.insert(args, dir)
  end

  local result = vim.system(args, {text = true}):wait()

  if result.code ~= 0 and result.stdout == "" then
    return {}
  end

  local files = {}
  for line in result.stdout:gmatch("[^\n]+") do
    table.insert(files, {
      path = line,
      mtime = get_mtime(line),
    })
  end

  table.sort(files, function(a, b)
    return a.mtime > b.mtime
  end)

  return files
end


-- Search file contents with rg, returns {path, linenum, text} per match
local function search_content(query, search_dirs, use_ignore_files, include_hidden)
  local args = {
    "rg",
    "--line-number",
    "--no-heading",
    "--with-filename",
    "--color=never",
    "--smart-case",
    "--no-messages",
  }

  if not use_ignore_files then
    table.insert(args, "--no-ignore")
  end

  if include_hidden then
    table.insert(args, "--hidden")
  end

  table.insert(args, "--")
  table.insert(args, query)

  for _, dir in ipairs(search_dirs) do
    table.insert(args, dir)
  end

  local result = vim.system(args, {text = true}):wait()

  if result.stdout == "" then
    return {}
  end

  local matches = {}
  for line in result.stdout:gmatch("[^\n]+") do
    local path, lnum, text = line:match("^(.-):(%d+):(.*)$")
    if path and lnum and text then
      table.insert(matches, {
        path = path,
        lnum = tonumber(lnum),
        text = text,
      })
    end
  end

  return matches
end


-- Search filenames for query (case insensitive)
local function search_filenames(query, files)
  local query_lower = query:lower()
  local matches = {}

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file.path, ":t"):lower()

    if filename:find(query_lower, 1, true) then
      table.insert(matches, {
        path = file.path,
        lnum = 1,
        text = nil,
        mtime = file.mtime,
      })
    end
  end

  return matches
end


-- Main search function
function M.search(query, opts)
  local search_dirs = opts.search_dirs
  local use_ignore_files = opts.use_ignore_files
  local include_hidden = opts.include_hidden
  local all_files = list_files(search_dirs, use_ignore_files, include_hidden)

  if not query or query == "" then
    return vim.tbl_map(function(file)
      return {
        path = file.path,
        lnum = 1,
        text = nil,
        mtime = file.mtime,
      }
    end, all_files)
  end

  local mtime_lookup = {}
  for _, file in ipairs(all_files) do
    mtime_lookup[file.path] = file.mtime
  end

  local filename_matches = search_filenames(query, all_files)
  local content_matches = search_content(query, search_dirs, use_ignore_files, include_hidden)

  -- Union of all results, deduped.  Filename matches take priority.
  -- For content matches, we take the first matching line per file.
  local seen = {}
  local results = {}

  -- Index filename matches first
  for _, match in ipairs(filename_matches) do
    if not seen[match.path] then
      seen[match.path] = true
      table.insert(results, match)
    end
  end

  -- Add content matches for files not already included.
  -- For files already included, we skip.  Deciding that filename is
  -- more useful context.
  for _, match in ipairs(content_matches) do
    local path = match.path
    if not seen[path] then
      seen[path] = true
      table.insert(results, {
        path = path,
        lnum = match.lnum,
        text = match.text,
        mtime = mtime_lookup[path] or 0,
      })
    end
  end

  -- Sort unified results by mtime
  table.sort(results, function(a, b)
    return a.mtime > b.mtime
  end)

  return results
end


return M
