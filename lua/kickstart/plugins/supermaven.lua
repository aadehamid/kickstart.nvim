-- supermaven-nvim - AI code completion plugin
return {
  {
    'supermaven-inc/supermaven-nvim',
    event = 'InsertEnter',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<Tab>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        ignore_filetypes = {
          -- Add any filetypes you want to ignore
          -- cpp = true,
        },
        color = {
          suggestion_color = '#808080', -- Gray color for suggestions
          cterm = 244,
        },
        log_level = 'info', -- set to "off" to disable logging completely
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false, -- disables built in keymaps for more manual control
        condition = function()
          return false -- condition to check for stopping supermaven
        end,
      })
    end,
  },
}
