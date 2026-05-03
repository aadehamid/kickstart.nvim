-- cmake.lua — CMake tools integration

---@module 'lazy'
---@type LazySpec
return {
  'Civitasv/cmake-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = { 'cmake' },
  cmd = {
    'CMakeGenerate',
    'CMakeBuild',
    'CMakeRun',
    'CMakeSelectBuildTarget',
    'CMakeSelectLaunchTarget',
    'CMakeSelectBuildType',
    'CMakeClean',
  },
  keys = {
    { '<leader>cg', '<cmd>CMakeGenerate<cr>', desc = '[C]Make [G]enerate (Configure)' },
    { '<leader>cb', '<cmd>CMakeBuild<cr>', desc = '[C]Make [B]uild' },
    { '<leader>cr', '<cmd>CMakeRun<cr>', desc = '[C]Make [R]un' },
    { '<leader>ct', '<cmd>CMakeSelectBuildTarget<cr>', desc = '[C]Make Select Build [T]arget' },
    { '<leader>cl', '<cmd>CMakeSelectLaunchTarget<cr>', desc = '[C]Make Select [L]aunch Target' },
    { '<leader>cs', '<cmd>CMakeSelectBuildType<cr>', desc = '[C]Make Select Build Type ([S]elect)' },
    { '<leader>cc', '<cmd>CMakeClean<cr>', desc = '[C]Make [C]lean' },
    { '<leader>cd', '<cmd>CMakeDebug<cr>', desc = '[C]Make [D]ebug' },
  },
  opts = {
    cmake_command = 'cmake',
    ctest_command = 'ctest',
    cmake_use_preset = true,
    cmake_regenerate_on_save = true,
    cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
    cmake_build_directory = 'build/${variant:buildType}',
    cmake_compile_commands_options = {
      action = 'soft_link',
      target = vim.uv.cwd,
    },
    cmake_dap_configuration = {
      name = 'cpp',
      type = 'codelldb',
      request = 'launch',
      stopOnEntry = false,
      runInTerminal = true,
      console = 'integratedTerminal',
    },
    cmake_executor = {
      name = 'quickfix',
      opts = {
        show = 'always',
        position = 'belowright',
        size = 10,
        auto_close_when_success = true,
      },
    },
    cmake_runner = {
      name = 'quickfix',
      opts = {
        show = 'always',
        position = 'belowright',
        size = 10,
      },
    },
    cmake_notifications = {
      runner = { enabled = true },
      executor = { enabled = true },
    },
  },
}
