-- lua/md_nav/toc.lua
-- Table of Contents: building and upserting under '^top'.

local cfg    = require("md_nav.config")
local utils  = require("md_nav.utils")
local sect   = require("md_nav.sections")

local M = {}

-- Markers ensure TOC block survives formatters / processors.
local MARK_START_HTML = "<!-- MDNAV:TOC START -->"
local MARK_END_HTML   = "<!-- MDNAV:TOC END -->"
local MARK_START_OBS  = "%% MDNAV:TOC START %%"
local MARK_END_OBS    = "%% MDNAV:TOC END %%"

local function is_start_marker(s)
  return s and (s:find("<!--%s*MDNAV:TOC START%s*-->") or s:find("%%%s*MDNAV:TOC START%s*%%"))
end
local function is_end_marker(s)
  return s and (s:find("<!--%s*MDNAV:TOC END%s*-->") or s:find("%%%s*MDNAV:TOC END%s*%%"))
end

---Find TOC blocks by explicit markers.
local function find_toc_blocks(lines)
  local blocks, i = {}, 1
  while i <= #lines do
    if is_start_marker(lines[i]) then
      local s = i - 1
      local e
      for j = i, #lines do
        if is_end_marker(lines[j]) then e = j - 1; break end
      end
      if e then
        blocks[#blocks + 1] = { s = s, e = e }
        i = e + 2
      else
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  return blocks
end

---Extract existing item labels from a TOC block (for new-only update logic).
local function toc_items_between(lines, s_idx, e_idx)
  local items = {}
  for i = s_idx + 1, e_idx - 1 do
    local L = lines[i + 1] or ""
    local disp = L:match("^>%s*%-+%s*%[%[#.+|(.+)%]%]") or L:match("^>%s*%-%s*%[%[#.+|(.+)%]%]")
    if disp then items[#items + 1] = disp end
  end
  return items
end

---Build canonical nested TOC (H2..max_depth). Does NOT include '^top'.
function M.build_toc_lines(bufnr)
  local lines = utils.get_lines(bufnr)
  local heads = sect.collect_headings(lines)
  local maxd  = math.min(cfg.get().max_depth or 4, 6)

  local out = {}
  out[#out + 1] = MARK_START_HTML
  out[#out + 1] = MARK_START_OBS
  out[#out + 1] = "> [!note]- 🔗 Quick Jump"

  local any = false
  for _, h in ipairs(heads) do
    if h.level >= 2 and h.level <= maxd then
      any = true
      local indent = string.rep("  ", h.level - 2) -- H2 no indent; deeper adds two spaces per level
      out[#out + 1] = string.format("> %s- [[#%s|%s]]", indent, h.text, h.text)
    end
  end

  if not any then
    out[#out + 1] = "> - _No headings found_"
  end

  out[#out + 1] = MARK_END_HTML
  out[#out + 1] = MARK_END_OBS
  out[#out + 1] = ""
  return out
end

---Insert or update a single canonical TOC under '^top' (idempotent).
---Assumes caller has already ensured H1 and '^top'. Removes duplicates.
---@param bufnr integer
---@param top_at_0 integer  -- 0-based index of '^top'
function M.upsert(bufnr, top_at_0)
  local lines  = utils.get_lines(bufnr)
  local heads  = sect.collect_headings(lines)
  local maxd   = math.min(cfg.get().max_depth or 4, 6)
  local any_sections = sect.has_sections(heads, maxd)

  -- Find existing blocks and keep the first one after '^top' as canonical.
  local blocks = find_toc_blocks(lines)
  local canonical
  for _, b in ipairs(blocks) do
    if b.s >= top_at_0 then canonical = b; break end
  end
  for _, b in ipairs(blocks) do
    if not canonical or b.s ~= canonical.s or b.e ~= canonical.e then
      utils.set_lines(bufnr, b.s, b.e + 1, {})
      lines = utils.get_lines(bufnr)
    end
  end

  if not any_sections then
    if canonical then utils.set_lines(bufnr, canonical.s, canonical.e + 1, {}) end
    return
  end

  local new_block = M.build_toc_lines(bufnr)
  if canonical then
    local items = toc_items_between(lines, canonical.s, canonical.e)
    local seen = {}
    for _, t in ipairs(items) do seen[t] = true end
    local needs_update = false
    for _, h in ipairs(heads) do
      if h.level >= 2 and h.level <= maxd and not seen[h.text] then
        needs_update = true; break
      end
    end
    if needs_update then
      utils.set_lines(bufnr, canonical.s, canonical.e + 1, new_block)
    end
  else
    local place_at = top_at_0 + 2 -- after '^top' + blank
    utils.set_lines(bufnr, place_at, place_at, new_block)
  end
end

-- expose helpers for tests
M._find_toc_blocks = find_toc_blocks
M._toc_items_between = toc_items_between
M.MARK_START_HTML = MARK_START_HTML
M.MARK_END_HTML   = MARK_END_HTML
M.MARK_START_OBS  = MARK_START_OBS
M.MARK_END_OBS    = MARK_END_OBS

return M
