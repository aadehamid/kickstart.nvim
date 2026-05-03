-- cpp.lua — Master C++ development configuration
-- Configures clangd LSP, clangd_extensions, formatting, mason tools, and treesitter parsers

---@module 'lazy'
---@type LazySpec
return {
  {
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    opts = {
      inlay_hints = {
        inline = true,
      },
      ast = {
        role_icons = {
          type = '🄣',
          declaration = '🄓',
          expression = '🄔',
          statement = ';',
          specifier = '🄢',
          ['template argument'] = '🆃',
        },
        kind_icons = {
          Compound = '🄲',
          Recovery = '🅁',
          TranslationUnit = '🅄',
          PackExpansion = '🄿',
          TemplateTypeParm = '🅃',
          TemplateTemplateParm = '🅃',
          TemplateParamObject = '🅃',
        },
      },
      memory_usage = {
        border = 'rounded',
      },
      symbol_info = {
        border = 'rounded',
      },
    },
    config = function(_, opts)
      require('clangd_extensions').setup(opts)

      -- Configure clangd LSP via vim.lsp.config / vim.lsp.enable
      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--completion-style=detailed',
          '--header-insertion=iwyu',
          '--fallback-style=llvm',
        },
        -- No fallbackFlags here — clangd auto-detects C vs C++.
        -- For projects, use a compile_commands.json or .clangd file instead.
        capabilities = {
          offsetEncoding = { 'utf-16' },
        },
      })
      vim.lsp.enable('clangd')
    end,
  },

  -- Add clang-format to conform.nvim formatters for C/C++
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        c = { 'clang-format' },
        cpp = { 'clang-format' },
      },
    },
  },

  -- Ensure mason installs C++ tooling
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        'clangd',
        'clang-format',
        'codelldb',
      })
    end,
  },

  -- Ensure treesitter installs C/C++ parsers
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function()
      -- On the main branch, parsers are installed imperatively
      -- Schedule this so it runs after treesitter is loaded
      vim.schedule(function()
        local ok, ts = pcall(require, 'nvim-treesitter')
        if ok then
          ts.install({ 'c', 'cpp' })
        end
      end)
    end,
  },
}
