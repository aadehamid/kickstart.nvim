-- run.lua — Quick compile & run commands

---@module 'lazy'
---@type LazySpec
return {
  dir = '.',
  name = 'run-keymaps',
  lazy = false,
  init = function()
    -- :Run  — compile & run C file
    vim.api.nvim_create_user_command('Run', function()
      vim.cmd('w')
      vim.cmd('term gcc % -o %< && ./%<')
    end, { desc = 'Compile & Run C file' })

    -- :Runcpp — compile & run C++ file
    vim.api.nvim_create_user_command('Runcpp', function()
      vim.cmd('w')
      vim.cmd('term g++ % -o %< && ./%<')
    end, { desc = 'Compile & Run C++ file' })
  end,
}
