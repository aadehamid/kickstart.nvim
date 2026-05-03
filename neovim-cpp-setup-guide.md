# Neovim C/C++ Development Setup Guide

> Complete setup for Neovim with kickstart.nvim on an exe.dev VM (Ubuntu 24.04).
> Tested: July 2025 | Neovim 0.11.1

---

## 1. Prerequisites

Verify these are installed (most come pre-installed on exe.dev VMs):

```bash
git --version
gcc --version
g++ --version
make --version
cmake --version
node --version
python3 --version
rg --version          # ripgrep
fdfind --version      # fd-find
unzip -v | head -1
curl --version | head -1
```

Install any missing ones:

```bash
sudo apt update && sudo apt install -y \
  git gcc g++ make cmake nodejs npm python3 python3-pip \
  ripgrep fd-find unzip curl xclip
```

---

## 2. Install Neovim 0.11+

The kickstart.nvim config requires Neovim 0.11+ (for `vim.diagnostic` and `vim.lsp.config` APIs).

```bash
# Download Neovim 0.11.1
curl -sLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz

# Extract to home directory
tar xzf nvim-linux-x86_64.tar.gz -C ~/

# Symlink to PATH
sudo ln -sf ~/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Verify
nvim --version | head -1
# Should show: NVIM v0.11.1

# Cleanup
rm nvim-linux-x86_64.tar.gz
```

---

## 3. Clone Kickstart Config

```bash
# Backup existing config if any
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone your fork
git clone https://github.com/aadehamid/kickstart.nvim.git ~/.config/nvim
```

---

## 4. Enable Custom Plugins

The custom plugins directory is disabled by default. Enable it:

```bash
# Edit init.lua — find and uncomment this line (around line 956):
#   -- { import = 'custom.plugins' },
# Change it to:
#   { import = 'custom.plugins' },

sed -i "s|-- { import = 'custom.plugins' },|{ import = 'custom.plugins' },|" ~/.config/nvim/init.lua
```

---

## 5. Fix Lazy.nvim Concurrency (DNS issues on VMs)

Lazy.nvim fires 50+ parallel git fetches which can overwhelm DNS. Limit concurrency:

```bash
# Edit init.lua — find the lazy.setup options block (around line 965):
#   }, { ---@diagnostic disable-line: missing-fields
#     ui = {
# Add concurrency = 4 before ui:

sed -i '/}, { ---@diagnostic disable-line: missing-fields/a\  concurrency = 4,' ~/.config/nvim/init.lua
```

Also add a fallback DNS resolver:

```bash
sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
```

---

## 6. Fix clangd fallbackFlags for C Compatibility

The default `cpp.lua` sets `-std=c++20` which breaks C files. Remove it:

```bash
# Edit ~/.config/nvim/lua/custom/plugins/cpp.lua
# Find and replace the init_options block:
#
#   init_options = {
#     fallbackFlags = { '-std=c++20' },
#   },
#
# Replace with:
#
#   -- No fallbackFlags — clangd auto-detects C vs C++.
#   -- For projects, use a compile_commands.json or .clangd file instead.

sed -i '/init_options = {/,/},/c\        -- No fallbackFlags — clangd auto-detects C vs C++.\n        -- For projects, use a compile_commands.json or .clangd file instead.' \
  ~/.config/nvim/lua/custom/plugins/cpp.lua
```

---

## 7. Add Quick Compile & Run Commands

Create `~/.config/nvim/lua/custom/plugins/run.lua`:

```bash
cat > ~/.config/nvim/lua/custom/plugins/run.lua << 'EOF'
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
EOF
```

---

## 8. Install Plugins & Tools

Launch Neovim and let everything install:

```bash
# Sync all Lazy plugins (retry if any fail due to DNS)
nvim --headless "+Lazy! sync" +qa

# Install Mason tools (clangd, clang-format, codelldb)
nvim --headless -c "MasonInstall clangd clang-format codelldb" -c "sleep 60" -c "qa"

# Install TreeSitter parsers
nvim --headless -c "TSInstall c cpp cmake" -c "sleep 15" -c "qa"
```

---

## 9. Verify Installation

```bash
# Check everything loads without errors
nvim --headless "+checkhealth" "+w! /tmp/health.txt" +qa
grep -E '✅|❌|⚠️' /tmp/health.txt

# Test LSP attaches to a C file
cat > /tmp/test.c << 'EOF'
#include <stdio.h>
int main(void) {
    printf("Hello\n");
    return 0;
}
EOF
nvim --headless /tmp/test.c -c "sleep 5" -c "lua print('LSP clients: ' .. #vim.lsp.get_clients())" -c "qa"
# Should show: LSP clients: 1
```

---

## What You Get

### Plugins Installed

| Plugin | Purpose |
|---|---|
| `clangd_extensions.nvim` | Enhanced clangd — inlay hints, AST viewer, symbol info |
| `conform.nvim` | Auto-formatting with `clang-format` |
| `cmake-tools.nvim` | CMake build/run/debug integration |
| `nvim-dap` + `codelldb` | C/C++ debugging |
| `nvim-treesitter` | Syntax highlighting for C/C++/CMake |

### Mason Tools

| Tool | Purpose |
|---|---|
| `clangd` | LSP server (autocomplete, diagnostics, go-to-def) |
| `clang-format` | Code formatter |
| `codelldb` | Debug adapter |

### Commands

| Command | Action |
|---|---|
| `:Run` | Save, compile & run current C file |
| `:Runcpp` | Save, compile & run current C++ file |
| `:Lazy sync` | Update all plugins |
| `:MasonToolsUpdate` | Update all Mason tools |
| `:TSUpdate` | Update all TreeSitter parsers |

### CMake Keybindings

| Key | Action |
|---|---|
| `<Space>cg` | CMake Generate (configure) |
| `<Space>cb` | CMake Build |
| `<Space>cr` | CMake Run |
| `<Space>cd` | CMake Debug |
| `<Space>ct` | Select build target |
| `<Space>cc` | CMake Clean |

### DAP (Debugger) Keybindings

| Key | Action |
|---|---|
| `<F5>` | Start/continue debugging |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<Space>b` | Toggle breakpoint |

---

## Troubleshooting

### Error: `opt: expected table, got string` on startup

**Cause:** Neovim 0.10.x doesn't support the `vim.diagnostic.config` API used in kickstart.nvim.
The config uses `float = { source = 'if_many' }` which requires Neovim 0.11+.

**Fix:** Upgrade Neovim to 0.11+ (see Step 2 above).

---

### Error: `fetch failed — Could not resolve host: github.com`

**Cause:** `:Lazy sync` fires 50+ parallel git fetches. The DNS resolver gets overwhelmed
and random plugins fail each time (different plugin every retry).

**Fix (two parts):**
1. Limit Lazy concurrency to 4 (see Step 5 above)
2. Add a fallback DNS resolver:
```bash
sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
```
Then retry `:Lazy sync` — it should pass cleanly.

---

### Error: `Invalid argument '-std=c++20' not allowed with 'C'`

**Cause:** The `cpp.lua` plugin sets `fallbackFlags = { '-std=c++20' }` in clangd config.
This flag is applied to ALL files including `.c` files, but C files reject C++ standard flags.

**Fix:** Remove the `fallbackFlags` from `cpp.lua` (see Step 6 above).
Clangd auto-detects the language from file extension (`.c` → C, `.cpp` → C++).
For project-specific standards, use `compile_commands.json` (from CMake) or a `.clangd` file.

---

### TreeSitter parsers not installed

**Cause:** TreeSitter parsers for C/C++ aren't included by default — they need to be
installed explicitly.

**Fix:** Run inside Neovim:
```
:TSInstall c cpp cmake
```
Or headlessly:
```bash
nvim --headless -c "TSInstall c cpp cmake" -c "sleep 15" -c "qa"
```
To update all parsers later: `:TSUpdate`

---

### Mason tools not installing automatically

**Cause:** `MasonToolsInstallSync` can silently fail. The `ensure_installed` list in `cpp.lua`
may not trigger on first launch.

**Fix:** Install manually:
```bash
nvim --headless -c "MasonInstall clangd clang-format codelldb" -c "sleep 60" -c "qa"
```
Or inside Neovim: `:MasonInstall clangd clang-format codelldb`

Verify with: `:Mason` (should show all three as installed).

---

## Quick One-Liner Setup (after cloning)

Copy-paste this entire block for a fresh VM:

```bash
# Install Neovim 0.11.1
curl -sLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz \
  && tar xzf nvim-linux-x86_64.tar.gz -C ~/ \
  && sudo ln -sf ~/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
  && rm nvim-linux-x86_64.tar.gz

# Clone config
git clone https://github.com/aadehamid/kickstart.nvim.git ~/.config/nvim

# Enable custom plugins
sed -i "s|-- { import = 'custom.plugins' },|{ import = 'custom.plugins' },|" ~/.config/nvim/init.lua

# Add concurrency limit
sed -i '/}, { ---@diagnostic disable-line: missing-fields/a\  concurrency = 4,' ~/.config/nvim/init.lua

# Fix clangd fallbackFlags
sed -i '/init_options = {/,/},/c\        -- No fallbackFlags — clangd auto-detects C vs C++.\n        -- For projects, use a compile_commands.json or .clangd file instead.' \
  ~/.config/nvim/lua/custom/plugins/cpp.lua

# Add Run commands
cat > ~/.config/nvim/lua/custom/plugins/run.lua << 'EOF'
return {
  dir = '.', name = 'run-keymaps', lazy = false,
  init = function()
    vim.api.nvim_create_user_command('Run', function()
      vim.cmd('w') vim.cmd('term gcc % -o %< && ./%<')
    end, { desc = 'Compile & Run C file' })
    vim.api.nvim_create_user_command('Runcpp', function()
      vim.cmd('w') vim.cmd('term g++ % -o %< && ./%<')
    end, { desc = 'Compile & Run C++ file' })
  end,
}
EOF

# Add fallback DNS
sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'

# Install everything
nvim --headless "+Lazy! sync" +qa
nvim --headless -c "MasonInstall clangd clang-format codelldb" -c "sleep 60" -c "qa"
nvim --headless -c "TSInstall c cpp cmake" -c "sleep 15" -c "qa"

echo "✅ Done! Run: nvim hello.c"
```
