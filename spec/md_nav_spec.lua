local md_nav = require("md_nav")

-- buffer helpers
local function set_lines(buf, lines) vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) end
local function get_lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end

-- single-assertion predicate
local function check_integration(lines_first, lines_second)
  if table.concat(lines_first, "\n") ~= table.concat(lines_second, "\n") then
    return false, "Buffer differs between first and second run"
  end
  local tops, footers = 0, 0
  for _, s in ipairs(lines_second) do
    if s == "^top" then tops = tops + 1 end
    if s == "[[#^top|↩️ Back to Top]]" then footers = footers + 1 end
  end
  if tops ~= 1 then return false, "Expected exactly one ^top, got " .. tops end
  if footers ~= 2 then return false, "Expected exactly two H2 footers, got " .. footers end
  return true, ""
end

describe("md_nav (integration)", function()
  local buf
  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
  end)
  after_each(function() if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end end)

  it("is idempotent and preserves invariants", function()
    set_lines(buf, {
      "---","created: 2025-09-10","---",
      "# Title",
      "## One","Text","### One.1","Text",
      "## Two","Text",
    })
    md_nav.update_nav()
    local once = get_lines(buf)
    md_nav.update_nav()
    local twice = get_lines(buf)
    local ok, msg = check_integration(once, twice)
    assert.is_true(ok, msg)
  end)
end)
