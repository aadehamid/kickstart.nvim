-- completion.lua
-- https://cmp.saghen.dev/installation

return {
  {
    'saghen/blink.cmp',
    dependencies = { 
      'rafamadriz/friendly-snippets',
      'neovim/nvim-lspconfig',
    },
    version = '1.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        nerd_font_variant = 'mono'
      },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      -- Load the plugin with options
      require('blink.cmp').setup(opts)
      
      -- Configure LSP capabilities - this will run after the plugin is loaded
      -- This hooks into the LSP setup process to ensure all servers use Blink's capabilities
      local lspconfig = require('lspconfig')
      local old_setup = lspconfig.util.default_config.on_setup
      
      lspconfig.util.default_config.on_setup = function(config)
        -- Add blink.cmp capabilities to the server config
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        
        -- Call the original setup function if it exists
        if old_setup then
          old_setup(config)
        end
      end
    end
  }
}