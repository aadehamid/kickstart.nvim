-- neogen.lua — Generate documentation comments (Doxygen for C++)

---@module 'lazy'
---@type LazySpec
return {
  'danymat/neogen',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  cmd = 'Neogen',
  keys = {
    { '<leader>dg', '<cmd>Neogen<cr>', desc = '[D]ocumentation [G]enerate' },
    { '<leader>df', '<cmd>Neogen func<cr>', desc = '[D]oc generate [F]unction' },
    { '<leader>dc', '<cmd>Neogen class<cr>', desc = '[D]oc generate [C]lass' },
    { '<leader>dt', '<cmd>Neogen type<cr>', desc = '[D]oc generate [T]ype' },
  },
  opts = {
    snippet_engine = 'luasnip',
    languages = {
      cpp = {
        template = {
          annotation_convention = 'doxygen',
        },
      },
      c = {
        template = {
          annotation_convention = 'doxygen',
        },
      },
    },
  },
}
