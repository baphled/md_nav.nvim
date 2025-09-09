-- lua/md_nav/back_to_top.lua
-- '^top' enforcement and per-section back-to-top footers.

local cfg    = require("md_nav.config")
local utils  = require("md_nav.utils")
local sect   = require("md_nav.sections")

local M = {}

local function level_configured_for_footer(level)
  for _, lv in ipairs(cfg.get().footer_levels or {}) do
    if lv == level then return true end
  end
  return false
end

---Ensure EXACTLY ONE '^top' at the canonical position (idempotent).
function M.ensure_single_top(bufnr, canonical_top_at)
  local lines = utils.get_lines(bufnr)
  local tops = {}
  for i, s in ipairs(lines) do
    if s == "^top" then tops[#tops + 1] = i - 1 end
  end
  for i = #tops, 1, -1 do
    local idx = tops[i]
    if idx ~= canonical_top_at then
      utils.set_lines(bufnr, idx, idx + 1, {})
    end
  end
  lines = utils.get_lines(bufnr)
  if lines[canonical_top_at + 1] ~= "^top" then
    utils.set_lines(bufnr, canonical_top_at, canonical_top_at, { "^top" })
  end
  lines = utils.get_lines(bufnr)
  if (lines[canonical_top_at + 2] or "") ~= "" then
    utils.set_lines(bufnr, canonical_top_at + 1, canonical_top_at + 1, { "" })
  end
end

---Remove an existing footer near the section end, if present.
local function remove_existing_footer(bufnr, lines, search_from_0, search_to_0)
  local rm_from, rm_to
  for j = search_from_0, search_to_0 do
    local L = lines[j + 1] or ""
    if L:find(utils.P_BTOS) then
      rm_from = j
      local k = j + 1
      while k <= search_to_0 and (lines[k + 1] or ""):match("^%s*$") do k = k + 1 end
      if k <= search_to_0 and (lines[k + 1] or ""):match("^%-%-%-%s*$") then
        rm_to = k
      else
        rm_to = j
      end
      break
    end
  end
  if rm_from and rm_to then
    utils.set_lines(bufnr, rm_from, rm_to + 1, {})
    return (rm_to - rm_from) + 1
  end
  return nil
end

---Place/normalize Back-to-Top footers after sections configured in footer_levels.
function M.upsert_section_footers(bufnr)
  if not utils.is_markdown(bufnr) then return end

  local lines = utils.get_lines(bufnr)
  local heads = sect.collect_headings(lines)
  if #heads == 0 or not (cfg.get().footer_levels and #cfg.get().footer_levels > 0) then return end

  for i = #heads, 1, -1 do
    local h = heads[i]
    if level_configured_for_footer(h.level) then
      local sec_end_0 = sect.section_end_index(heads, i, #lines)

      local win_from_0 = math.max(h.idx + 1, sec_end_0 - 12)
      local win_to_0   = sec_end_0

      local removed = remove_existing_footer(bufnr, lines, win_from_0, win_to_0)
      if removed then
        lines = utils.get_lines(bufnr)
        sec_end_0 = sec_end_0 - removed
      end

      lines = utils.get_lines(bufnr)
      local need_blank = not ((lines[sec_end_0 + 1] or ""):match("^%s*$"))
      local footer = {}
      if need_blank then footer[#footer + 1] = "" end
      footer[#footer + 1] = "[[#^top|↩️ Back to Top]]"
      footer[#footer + 1] = ""
      footer[#footer + 1] = cfg.get().hr or "---"

      utils.set_lines(bufnr, sec_end_0 + 1, sec_end_0 + 1, footer)
      lines = utils.get_lines(bufnr)
    end
  end
end

-- expose helpers for tests
M._remove_existing_footer = remove_existing_footer

return M
