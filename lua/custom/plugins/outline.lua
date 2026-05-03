-- outline.lua — Symbol outline sidebar

---@module 'lazy'
---@type LazySpec
return {
  'hedyhli/outline.nvim',
  cmd = { 'Outline', 'OutlineOpen', 'OutlineClose' },
  keys = {
    { '<leader>o', '<cmd>Outline<cr>', desc = 'Toggle symbol [O]utline' },
  },
  opts = {
    outline_window = {
      position = 'right',
      width = 30,
      relative_width = false,
      auto_close = false,
      auto_jump = false,
    },
    outline_items = {
      show_symbol_details = true,
      show_symbol_lineno = true,
    },
    symbol_folding = {
      autofold_depth = 1,
      auto_unfold = {
        hovered = true,
        only = 2,
      },
    },
    symbols = {
      filter = {
        default = {
          'Class',
          'Constructor',
          'Enum',
          'Field',
          'Function',
          'Interface',
          'Method',
          'Module',
          'Namespace',
          'Property',
          'Struct',
          'Variable',
        },
      },
    },
    preview_window = {
      auto_preview = true,
      border = 'rounded',
    },
  },
}
