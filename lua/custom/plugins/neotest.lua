-- neotest.lua — Test runner with Google Test support

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'alfaix/neotest-gtest',
  },
  keys = {
    {
      '<leader>tn',
      function() require('neotest').run.run() end,
      desc = '[T]est [N]earest',
    },
    {
      '<leader>tf',
      function() require('neotest').run.run(vim.fn.expand '%') end,
      desc = '[T]est [F]ile',
    },
    {
      '<leader>ts',
      function() require('neotest').summary.toggle() end,
      desc = '[T]est [S]ummary toggle',
    },
    {
      '<leader>to',
      function() require('neotest').output_panel.toggle() end,
      desc = '[T]est [O]utput toggle',
    },
    {
      '<leader>tp',
      function() require('neotest').output.open { enter = true } end,
      desc = '[T]est output [P]eek',
    },
    {
      '<leader>td',
      function() require('neotest').run.run { strategy = 'dap' } end,
      desc = '[T]est [D]ebug nearest',
    },
    {
      '<leader>tl',
      function() require('neotest').run.run_last() end,
      desc = '[T]est run [L]ast',
    },
  },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('neotest').setup {
      adapters = {
        require 'neotest-gtest',
      },
      ---@diagnostic disable-next-line: missing-fields
      status = {
        virtual_text = true,
        signs = true,
      },
      ---@diagnostic disable-next-line: missing-fields
      output = {
        open_on_run = false,
      },
      ---@diagnostic disable-next-line: missing-fields
      quickfix = {
        open = function()
          vim.cmd 'copen'
        end,
      },
    }
  end,
}
