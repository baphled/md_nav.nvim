-- lua/md_nav/init.lua
-- Orchestrator: wires frontmatter, ^top, TOC, and footers.
-- Public API:
--   require("md_nav").setup(opts)
--   require("md_nav").update_nav()

local M = {}

local cfg    = require("md_nav.config")
local utils  = require("md_nav.utils")
local fm     = require("md_nav.frontmatter")
local btop   = require("md_nav.back_to_top")
local toc    = require("md_nav.toc")

function M.setup(opts) cfg.setup(opts) end
function M._get_cfg() return cfg.get() end

local function get_lines(bufnr) return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) end

---Main entry: enforce H1 → ^top → TOC → footers (idempotent)
function M.update_nav()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = get_lines(bufnr)
  if not utils.is_markdown(bufnr) then return end
  if not fm.find_frontmatter(lines) then return end

  -- Ensure frontmatter and H1
  local fm_end = fm.ensure_frontmatter(bufnr)
  local h1_0   = select(1, fm.ensure_h1(bufnr, fm_end))

  -- Place a blank after H1 and enforce a single '^top'
  fm.ensure_blank_after(bufnr, h1_0)
  local top_at_0 = h1_0 + 2
  btop.ensure_single_top(bufnr, top_at_0)

  -- Upsert TOC directly under '^top'
  toc.upsert(bufnr, top_at_0)

  -- Upsert per-section (e.g., H2) footers
  btop.upsert_section_footers(bufnr)
end

return M
