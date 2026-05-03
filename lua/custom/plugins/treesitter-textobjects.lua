-- treesitter-textobjects.lua — Syntax-aware text objects, select, move, swap
-- Compatible with nvim-treesitter main branch API

---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = 'VeryLazy',
  config = function()
    local tso = require 'nvim-treesitter-textobjects'

    tso.setup {
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v',
          ['@function.outer'] = 'V',
          ['@class.outer'] = 'V',
        },
        include_surrounding_whitespace = false,
      },
      move = {
        set_jumps = true,
      },
    }

    local select = require 'nvim-treesitter-textobjects.select'
    local move = require 'nvim-treesitter-textobjects.move'
    local swap = require 'nvim-treesitter-textobjects.swap'

    -- ── Select text objects ───────────────────────────────────────────
    local select_maps = {
      -- function
      { 'af', '@function.outer', 'Around function' },
      { 'if', '@function.inner', 'Inner function' },
      -- class
      { 'ac', '@class.outer', 'Around class' },
      { 'ic', '@class.inner', 'Inner class' },
      -- parameter / argument
      { 'aa', '@parameter.outer', 'Around argument/parameter' },
      { 'ia', '@parameter.inner', 'Inner argument/parameter' },
      -- conditional
      { 'ai', '@conditional.outer', 'Around conditional' },
      { 'ii', '@conditional.inner', 'Inner conditional' },
      -- loop
      { 'al', '@loop.outer', 'Around loop' },
      { 'il', '@loop.inner', 'Inner loop' },
    }

    for _, map in ipairs(select_maps) do
      vim.keymap.set({ 'x', 'o' }, map[1], function()
        select.select_textobject(map[2], 'textobjects')
      end, { desc = 'Select: ' .. map[3] })
    end

    -- ── Move to text objects ──────────────────────────────────────────
    -- Next start
    vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
      move.goto_next_start('@function.outer', 'textobjects')
    end, { desc = 'Next function start' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
      move.goto_next_start('@class.outer', 'textobjects')
    end, { desc = 'Next class start' })

    -- Next end
    vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
      move.goto_next_end('@function.outer', 'textobjects')
    end, { desc = 'Next function end' })
    vim.keymap.set({ 'n', 'x', 'o' }, ']C', function()
      move.goto_next_end('@class.outer', 'textobjects')
    end, { desc = 'Next class end' })

    -- Previous start
    vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
      move.goto_previous_start('@function.outer', 'textobjects')
    end, { desc = 'Previous function start' })
    vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
      move.goto_previous_start('@class.outer', 'textobjects')
    end, { desc = 'Previous class start' })

    -- Previous end
    vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
      move.goto_previous_end('@function.outer', 'textobjects')
    end, { desc = 'Previous function end' })
    vim.keymap.set({ 'n', 'x', 'o' }, '[C', function()
      move.goto_previous_end('@class.outer', 'textobjects')
    end, { desc = 'Previous class end' })

    -- ── Swap parameters ──────────────────────────────────────────────
    vim.keymap.set('n', '<leader>sa', function()
      swap.swap_next '@parameter.inner'
    end, { desc = '[S]wap next [A]rgument' })
    vim.keymap.set('n', '<leader>sA', function()
      swap.swap_previous '@parameter.inner'
    end, { desc = '[S]wap previous [A]rgument' })
  end,
}
