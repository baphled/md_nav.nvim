-- lua/md_nav/config.lua
-- Centralized configuration with sane defaults.

local M = {}

local DEFAULTS = {
  max_depth          = 4,        -- include H2..H{max_depth} in TOC (2..6)
  footer_levels      = { 2 },    -- add Back-to-Top under these heading levels
  prettify_h1        = true,     -- prettify H1 generated from filename
  create_frontmatter = true,     -- create minimal YAML frontmatter if missing
  debounce_ms        = 200,      -- BufWritePost debounce
  hr                 = "---",    -- footer separator
}

local CFG = vim.deepcopy(DEFAULTS)

function M.setup(opts)
  if type(opts) == "table" then
    for k, v in pairs(opts) do CFG[k] = v end
  end
end

function M.get() return CFG end
function M.reset_for_tests()
  CFG = vim.deepcopy(DEFAULTS)
end

return M
