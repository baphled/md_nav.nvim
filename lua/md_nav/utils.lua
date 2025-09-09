-- lua/md_nav/utils.lua
-- Small pure utilities and common patterns.

local M = {}

-- Patterns
M.P_YAML_DELIM   = "^%-%-%-%s*$"
function M.P_ATX(level) return "^" .. string.rep("#", level) .. "%s+(.+)" end
M.P_WHOLE_HEADING = "^#+%s+(.+)"
M.P_TOC_CALLOUT   = "^>%s*%[!note%]%s*%-?%s*🔗%s*Quick%s+Jump"
M.P_BTOS          = "%[%[#%s*%^^?top|%s*↩️%s*Back to Top%]%]"

function M.get_lines(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

function M.set_lines(bufnr, s, e, new)
  vim.api.nvim_buf_set_lines(bufnr, s, e, false, new)
end

function M.is_markdown(bufnr)
  local ft = vim.bo[bufnr].filetype
  return ft == "markdown" or ft == "mdx" or ft == "rmarkdown"
end

function M.trim_trailing_hashes(s)
  return (s:gsub("%s*#*%s*$", ""))
end

function M.basename_no_ext(path)
  local name = path:gsub(".*/", "")
  name = name:gsub("%.%w+$", "")
  return name
end

function M.prettify_title(s)
  s = s:gsub("[-_]+", " ")
  s = s:gsub("^%l", string.upper)
  s = s:gsub(" (%l)", function(c) return " " .. c:upper() end)
  return s
end

return M
