-- telescope-ast-grep.nvim plugin configuration
-- AST-based search through Telescope integration

return {
  'ray-x/telescope-ast-grep.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    -- Load the telescope extension
    require('telescope').load_extension('ast_grep')
    
    -- Set up keybindings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }
    
    -- AST-based search through Telescope
    keymap('n', '<leader>ag', '<cmd>Telescope AST_grep<CR>', vim.tbl_extend('force', opts, { desc = '[A]ST [G]rep with Telescope' }))
    keymap('v', '<leader>ag', '<cmd>Telescope AST_grep<CR>', vim.tbl_extend('force', opts, { desc = '[A]ST [G]rep with Telescope' }))
    
    -- Alternative keybindings for easier access  
    keymap('n', '<leader>sa', '<cmd>Telescope AST_grep<CR>', vim.tbl_extend('force', opts, { desc = '[S]earch [A]ST grep' }))
    
    -- Add to which-key groups if available
    local ok, wk = pcall(require, 'which-key')
    if ok then
      wk.add({
        { '<leader>a', group = '[A]ST Tools' },
        { '<leader>ag', desc = '[A]ST [G]rep with Telescope' },
      })
    end
    
    -- Custom commands for easier usage
    vim.api.nvim_create_user_command('AstGrep', function()
      vim.cmd('Telescope AST_grep')
    end, { desc = 'Open AST grep in Telescope' })
    
    -- Alternative jump commands using built-in telescope functionality
    vim.api.nvim_create_user_command('JumpToSymbol', function()
      require('telescope.builtin').lsp_workspace_symbols()
    end, { desc = 'Jump to symbol using LSP' })
    
    vim.api.nvim_create_user_command('JumpToDefinition', function()
      require('telescope.builtin').lsp_definitions()
    end, { desc = 'Jump to definition using LSP' })
    
    vim.api.nvim_create_user_command('JumpToReferences', function()
      require('telescope.builtin').lsp_references()
    end, { desc = 'Jump to references using LSP' })
    
    -- Show help/info command
    vim.api.nvim_create_user_command('AstGrepInfo', function()
      print('telescope-ast-grep.nvim commands:')
      print('  <leader>ag  - AST grep with Telescope')
      print('  <leader>sa  - Search AST grep (alternative)')
      print('')
      print('Direct commands:')
      print('  :AstGrep            - Open AST grep')
      print('  :JumpToSymbol       - Jump to symbol (LSP)')
      print('  :JumpToDefinition   - Jump to definition (LSP)')
      print('  :JumpToReferences   - Jump to references (LSP)')
      print('')
      print('Usage examples:')
      print('  console.log($$$)    - Find all console.log calls')
      print('  function $NAME($ARGS) { $$$ } - Find functions')
      print('  class $NAME { $$$ } - Find class definitions')
      print('')
      print('Supported languages:')
      print('  JavaScript, TypeScript, Python, Go, Rust, Java, C/C++, and more')
      print('  See: https://ast-grep.github.io/reference/languages.html')
    end, { desc = 'Show telescope-ast-grep help and commands' })
  end,
  
  -- Load on command or keymap
  keys = {
    '<leader>ag',
    '<leader>sa',
  },
  
  cmd = {
    'AstGrep',
    'JumpToSymbol',
    'JumpToDefinition', 
    'JumpToReferences',
    'AstGrepInfo',
  },
}
