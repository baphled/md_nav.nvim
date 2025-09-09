local sect = require("md_nav.sections")

local function check_collect_headings(lines)
  local heads = sect.collect_headings(lines)
  if #heads ~= 3 then return false, "Expected 3 headings, got " .. #heads end
  if heads[1].level ~= 1 or heads[2].level ~= 2 or heads[3].level ~= 3 then
    return false, "Heading levels incorrect"
  end
  return true, ""
end

local function check_section_end(lines)
  local heads = sect.collect_headings(lines)
  local end0 = sect.section_end_index(heads, 2, #lines) -- for H2
  -- Next <= level is H2 at line index 8 (1-based), so end should be just before
  -- Build expectation carefully: lines are 1-based here
  -- Our lines: 1:#,2:## A,3:txt,4:### sub,5:txt,6:txt,7:## B,8:txt
  -- For H2 at idx 2 (0-based 1), next H2 is at line 7 (0-based 6), so end0 = 5 (line 6)
  local expected_end0 = 6 - 1 -- 0-based
  if end0 ~= expected_end0 then
    return false, ("Expected section end at 0-based %d, got %d"):format(expected_end0, end0)
  end
  return true, ""
end

describe("sections (unit)", function()
  it("collect_headings returns correct levels", function()
    local lines = {
      "# H1", "## H2", "### H3",
    }
    local ok, msg = check_collect_headings(lines)
    assert.is_true(ok, msg)
  end)

  it("section_end_index returns the boundary before next <= level", function()
    local lines = {
      "# Top",
      "## A", "text",
      "### sub", "text",
      "text",
      "## B", "text",
    }
    local ok, msg = check_section_end(lines)
    assert.is_true(ok, msg)
  end)
end)
