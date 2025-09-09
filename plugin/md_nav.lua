-- plugin/md_nav.lua
-- Command + autocmd registration.

local group = vim.api.nvim_create_augroup("MDNav", { clear = true })
local last_run = 0

vim.api.nvim_create_user_command("MDNav", function()
  pcall(function() require("md_nav").update_nav() end)
end, { desc = "MDNav: Update TOC (frontmatter-aware, idempotent) + footers" })

vim.schedule(function()
  local ok, md = pcall(require, "md_nav")
  if not ok then return end
  local cfg = md._get_cfg and md._get_cfg() or { debounce_ms = 200 }

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = { "*.md", "*.markdown", "*.mdx" },
    callback = function()
      local now = vim.loop.now()
      if now - last_run < (cfg.debounce_ms or 200) then return end
      last_run = now
      pcall(function() require("md_nav").update_nav() end)
    end,
    desc = "MDNav: maintain H1/^top/TOC + footers automatically",
  })
end)
