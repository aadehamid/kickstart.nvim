-- glance.lua — Peek at definitions, references, type definitions, implementations

---@module 'lazy'
---@type LazySpec
return {
  'DNLHC/glance.nvim',
  cmd = 'Glance',
  keys = {
    { 'gD', '<cmd>Glance definitions<cr>', desc = 'Glance: Peek [D]efinitions' },
    { 'gR', '<cmd>Glance references<cr>', desc = 'Glance: Peek [R]eferences' },
    { 'gY', '<cmd>Glance type_definitions<cr>', desc = 'Glance: Peek T[Y]pe Definitions' },
    { 'gM', '<cmd>Glance implementations<cr>', desc = 'Glance: Peek I[M]plementations' },
  },
  opts = {
    border = {
      enable = true,
    },
    height = 20,
    detached = function(winid)
      return vim.api.nvim_win_get_width(winid) < 100
    end,
    preview_win_opts = {
      cursorline = true,
      number = true,
      wrap = false,
    },
    theme = {
      enable = true,
      mode = 'auto',
    },
    hooks = {
      -- Jump directly when there's only one result
      before_open = function(results, open, jump, _method)
        if #results == 1 then
          jump(results[1])
        else
          open(results)
        end
      end,
    },
  },
}
