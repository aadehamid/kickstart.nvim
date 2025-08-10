-- noice.nvim - highly experimental plugin that completely replaces the UI for messages, cmdline and popupmenu
return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- Required dependency
      'MunifTanjim/nui.nvim',
      -- Optional but recommended for notifications
      'rcarriga/nvim-notify',
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
    config = function(_, opts)
      require('noice').setup(opts)
      
      -- Recommended keymaps
      vim.keymap.set('n', '<leader>nd', '<cmd>Noice dismiss<CR>', { desc = 'Dismiss Noice messages' })
      vim.keymap.set('n', '<leader>nh', '<cmd>Noice history<CR>', { desc = 'Show Noice history' })
      vim.keymap.set('n', '<leader>nl', '<cmd>Noice last<CR>', { desc = 'Show last Noice message' })
      vim.keymap.set('n', '<leader>ne', '<cmd>Noice errors<CR>', { desc = 'Show Noice errors' })
    end,
  },
  -- Configure nvim-notify to work well with noice
  {
    'rcarriga/nvim-notify',
    opts = {
      background_colour = '#000000',
      render = 'minimal',
      stages = 'fade',
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      -- Set nvim-notify as the default notification handler
      vim.notify = require('notify')
    end,
  },
}
