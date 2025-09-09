local toc   = require("md_nav.toc")
local fm    = require("md_nav.frontmatter")
local utils = require("md_nav.utils")
local cfg   = require("md_nav.config")

local function set_lines(buf, lines) vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) end
local function get_lines(buf) return vim.api.nvim_buf_get_lines(buf, 0, -1, false) end

local function check_toc_markers_and_entries(buf)
  local out = get_lines(buf)
  local function find_eq(s) for i, L in ipairs(out) do if L == s then return i end end end
  local function find_re(p) for i, L in ipairs(out) do if L:match(p) then return i end end end

  local callout = find_re("^>%s*%[!note%]%s*%-?%s*🔗%s*Quick%s+Jump")
  if not callout then return false, "TOC callout missing" end

  local html_s = find_re("^<!%-%-%s*MDNAV:TOC START%s*%-%->$")
  local html_e = find_re("^<!%-%-%s*MDNAV:TOC END%s*%-%->$")
  local obs_s  = find_eq("%% MDNAV:TOC START %%")
  local obs_e  = find_eq("%% MDNAV:TOC END %%")
  if not (html_s and html_e and obs_s and obs_e) then
    return false, "TOC markers missing"
  end

  local h2  = find_eq("> - [[#One|One]]")
  local h3  = find_eq(">   - [[#One.1|One.1]]")
  local h2b = find_eq("> - [[#Two|Two]]")
  if not (h2 and h3 and h2b) then
    return false, "Missing nested TOC items"
  end

  return true, ""
end

describe("toc (unit)", function()
  local buf
  before_each(function()
    buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
    cfg.reset_for_tests()
  end)
  after_each(function() if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end end)

  it("builds and upserts nested TOC under ^top with markers", function()
    set_lines(buf, {
      "---","created: 2025-09-11","---",
      "# Title","","^top","",
      "## One","Text","### One.1","Text",
      "## Two","Text",
    })
    toc.upsert(buf, 5) -- '^top' at 0-based index 5
    local ok, msg = check_toc_markers_and_entries(buf)
    assert.is_true(ok, msg)
  end)
end)
