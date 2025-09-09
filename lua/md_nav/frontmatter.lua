-- lua/md_nav/frontmatter.lua
-- YAML frontmatter and H1 enforcement.

local cfg   = require("md_nav.config")
local utils = require("md_nav.utils")

local M = {}

---Find YAML frontmatter block at the top (skip leading blanks).
---@param lines string[]
---@return integer|nil fm_start_0, integer|nil fm_end_0
function M.find_frontmatter(lines)
  local i = 1
  while i <= #lines and lines[i]:match("^%s*$") do i = i + 1 end
  if i <= #lines and lines[i]:match(utils.P_YAML_DELIM) then
    local s = i - 1
    i = i + 1
    while i <= #lines and not lines[i]:match(utils.P_YAML_DELIM) do i = i + 1 end
    if i <= #lines then return s, i - 1 end
  end
  return nil, nil
end

---Find first H1 after a given 0-based index.
function M.find_h1(lines, from_0)
  local start = (from_0 or -1) + 2
  for i = start, #lines do
    local text = lines[i]:match(utils.P_ATX(1))
    if text then return i - 1, utils.trim_trailing_hashes(text) end
  end
  return nil, nil
end

---Ensure frontmatter exists; return its end index (0-based).
function M.ensure_frontmatter(bufnr)
  local lines = utils.get_lines(bufnr)
  local fm_s, fm_e = M.find_frontmatter(lines)
  if fm_s then return fm_e end
  return 1
end

---Ensure H1 appears just after frontmatter; return its 0-based index and text.
function M.ensure_h1(bufnr, fm_end_0)
  local lines = utils.get_lines(bufnr)
  local h1_idx, h1_text = M.find_h1(lines, fm_end_0)
  if h1_idx then return h1_idx, h1_text end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  local raw   = utils.basename_no_ext(fname ~= "" and fname or "Untitled")
  local title = cfg.get().prettify_h1 and utils.prettify_title(raw) or raw
  local h1    = "# " .. title

  local after_fm = lines[fm_end_0 + 2] or ""
  if after_fm ~= "" then utils.set_lines(bufnr, fm_end_0 + 1, fm_end_0 + 1, { "" }) end
  utils.set_lines(bufnr, fm_end_0 + 2, fm_end_0 + 2, { h1, "" })
  return fm_end_0 + 2, title
end

---Ensure exactly one blank line after a given 0-based index.
function M.ensure_blank_after(bufnr, idx0)
  local lines = utils.get_lines(bufnr)
  local next_line = lines[idx0 + 2] or ""
  if next_line ~= "" then utils.set_lines(bufnr, idx0 + 1, idx0 + 1, { "" }) end
end

return M
