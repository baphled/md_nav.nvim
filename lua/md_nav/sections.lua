-- lua/md_nav/sections.lua
-- Heading discovery and section boundaries.

local utils = require("md_nav.utils")

local M = {}

---Collect all headings (level 1..6).
---@param lines string[]
---@return { idx: integer, level: integer, text: string }[]
function M.collect_headings(lines)
  local heads = {}
  for i, line in ipairs(lines) do
    local hashes, text = line:match("^(#+)%s+(.+)")
    if hashes and text then
      local lvl = #hashes
      if lvl >= 1 and lvl <= 6 then
        heads[#heads + 1] = { idx = i - 1, level = lvl, text = utils.trim_trailing_hashes(text) }
      end
    end
  end
  return heads
end

function M.has_sections(heads, max_depth)
  for _, h in ipairs(heads) do
    if h.level >= 2 and h.level <= max_depth then return true end
  end
  return false
end

---Return the last 0-based line index belonging to heads[i]'s section.
---A section ends *before* the next heading with level <= current, or at EOF.
function M.section_end_index(heads, i, total_lines)
  local cur = heads[i].level
  for j = i + 1, #heads do
    if heads[j].level <= cur then
      return heads[j].idx - 1
    end
  end
  return total_lines - 1
end

return M
