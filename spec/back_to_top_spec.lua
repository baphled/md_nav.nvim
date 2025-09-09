local btop  = require("md_nav.back_to_top")
local sect  = require("md_nav.sections")
local utils = require("md_nav.utils")
local cfg   = require("md_nav.config")

local function set_lines(buf, lines) vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) end
local function get_lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end

local function check_single_top(lines, h1_line_idx)
  local tops = 0; local pos_ok = false
  for i, s in ipairs(lines) do if s == "^top" then tops = tops + 1; pos_ok = pos_ok or (i == h1_line_idx + 2) end end
  if tops ~= 1 then return false, "Expected exactly one ^top, got " .. tops end
  if not pos_ok then return false, "^top not placed directly under H1" end
  return true, ""
end

local function check_footer_after_subsections(lines)
  local idx_beta  = nil
  for i, s in ipairs(lines) do if s:match("^##%s+Beta$") then idx_beta = i break end end
  if not idx_beta then return false, "Missing H2 Beta" end
  local footer
  for i = idx_beta - 1, 1, -1 do if lines[i] == "[[#^top|↩️ Back to Top]]" then footer = i break end end
  if not footer then return false, "Footer not found before Beta" end
  if lines[footer + 2] ~= (cfg.get().hr or "---") and lines[footer + 3] ~= (cfg.get().hr or "---") then
    return false, "Footer HR not found"
  end
  return true, ""
end

describe("back_to_top (unit)", function()
  local buf
  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
    cfg.reset_for_tests()
  end)
  after_each(function() if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end end)

  it("ensures exactly one ^top at canonical position", function()
    set_lines(buf, { "---","---","","# T","","^top","","^top" })
    btop.ensure_single_top(buf, 5) -- H1 at 3 => top at 5
    local ok, msg = check_single_top(get_lines(buf), 4)
    assert.is_true(ok, msg)
  end)

  it("adds H2 footer after nested subsections", function()
    set_lines(buf, {
      "---","---","","# T","","^top","",
      "## A","text","### A.1","text",
      "## Beta","text",
    })
    btop.upsert_section_footers(buf)
    local ok, msg = check_footer_after_subsections(get_lines(buf))
    assert.is_true(ok, msg)
  end)
end)
