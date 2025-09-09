local fm    = require("md_nav.frontmatter")
local utils = require("md_nav.utils")
local cfg   = require("md_nav.config")

local function set_lines(buf, lines) vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) end
local function get_lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end

-- Accept H1 either immediately after frontmatter or after a single blank line
local function check_h1_created_after_frontmatter(lines)
  local fm_s, fm_e = fm.find_frontmatter(lines)
  if not (fm_s and fm_e) then return false, "Frontmatter not found" end

  local h1_idx, _ = fm.find_h1(lines, fm_e)
  if not h1_idx then return false, "H1 not found after frontmatter" end

  -- Zero-based indices: H1 can be at fm_e+1 (no blank) or fm_e+2 (one blank)
  local ok = (h1_idx == fm_e + 1) or (h1_idx == fm_e + 2)
  if not ok then
    return false, ("H1 should be directly after frontmatter or one line below (got 0-based %d, fm_end=%d)"):format(h1_idx, fm_e)
  end
  return true, ""
end

local function check_blank_after_h1(lines)
  for i, s in ipairs(lines) do
    if s:match("^#%s+") then
      if lines[i + 1] ~= "" then return false, "No blank line after H1" end
      return true, ""
    end
  end
  return false, "H1 not found"
end

describe("frontmatter (unit)", function()
  local buf
  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
    cfg.reset_for_tests()
  end)
  after_each(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  it("ensure_h1 creates under frontmatter", function()
    set_lines(buf, { "---", "---", "" })
    local fm_end = 1 -- 0-based, since lines 1:'---', 2:'---'
    fm.ensure_h1(buf, fm_end)
    local ok, msg = check_h1_created_after_frontmatter(get_lines(buf))
    assert.is_true(ok, msg)
  end)

  it("ensure_blank_after inserts a blank", function()
    set_lines(buf, { "---", "---", "", "# T", "no-blank" })
    fm.ensure_blank_after(buf, 3)
    local ok, msg = check_blank_after_h1(get_lines(buf))
    assert.is_true(ok, msg)
  end)
end)
