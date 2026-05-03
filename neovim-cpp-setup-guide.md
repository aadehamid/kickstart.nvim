# Neovim C/C++ Development Setup Guide

> Complete setup for Neovim with kickstart.nvim on an exe.dev VM (Ubuntu 24.04).
> Tested: November 2025 | Neovim 0.11.1

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

Install any missing ones (cmake and fd-find are commonly missing on fresh VMs):

```bash
sudo apt update && sudo apt install -y \
  git gcc g++ make cmake nodejs npm python3 python3-pip \
  ripgrep fd-find unzip curl xclip
```

---

## 2. Remove old Neovim & install Neovim 0.11+

The kickstart.nvim config requires Neovim 0.11+ (for `vim.diagnostic` and `vim.lsp.config` APIs).
Ubuntu 24.04 ships Neovim 0.9.5 in `/usr/bin/nvim` — **remove it first** so it doesn't shadow the new one.

```bash
# Remove the Ubuntu-packaged Neovim 0.9.5 (otherwise it stays in PATH and breaks the config)
sudo apt remove -y neovim neovim-runtime

# Download Neovim 0.11.1
curl -sLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz

# Extract to home directory
tar xzf nvim-linux-x86_64.tar.gz -C ~/

# Symlink to PATH
sudo ln -sf ~/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Verify
hash -r              # clear bash command cache
nvim --version | head -1
# Should show: NVIM v0.11.1

# Cleanup
rm nvim-linux-x86_64.tar.gz
```

> ⚠️ If `nvim --version` still reports 0.9.5, your shell cached the old path.
> Run `hash -r` or open a new terminal.

---

## 3. Install tree-sitter CLI

The `nvim-treesitter` plugin (main branch) compiles parsers from source and **requires the
`tree-sitter` CLI to be on PATH**. It is NOT bundled. Install it via npm:

```bash
npm install -g tree-sitter-cli --prefix ~/.local
tree-sitter --version    # should print 0.26+ (requires ~/.local/bin in PATH)
```

---

## 4. Clone Kickstart Config

```bash
# Backup existing config if any
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone the exe_dot_dev branch (already contains the patches in steps 5–8)
git clone -b exe_dot_dev https://github.com/aadehamid/kickstart.nvim.git ~/.config/nvim
```

The `exe_dot_dev` branch already includes:
- Custom plugins enabled in `init.lua`
- `concurrency = 4` for Lazy.nvim (DNS-friendly)
- Fixed `cpp.lua` (no `fallbackFlags` — clangd auto-detects C vs C++)
- `run.lua` providing `:Run` / `:Runcpp`
- A pinned `nvim-treesitter` commit (see Step 7) compatible with Neovim 0.11

If you are starting from a different branch, apply Steps 5, 6, 7, 8 manually.

---

## 5. Enable Custom Plugins (already done on `exe_dot_dev`)

```bash
sed -i "s|-- { import = 'custom.plugins' },|{ import = 'custom.plugins' },|" ~/.config/nvim/init.lua
```

---

## 6. Fix Lazy.nvim Concurrency + DNS (already done on `exe_dot_dev`)

Lazy.nvim fires 50+ parallel git fetches which can overwhelm DNS:

```bash
sed -i '/}, { ---@diagnostic disable-line: missing-fields/a\  concurrency = 4,' ~/.config/nvim/init.lua
```

Add a fallback DNS resolver (always do this on every fresh VM):

```bash
grep -q '8.8.8.8' /etc/resolv.conf || sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
```

---

## 7. Pin nvim-treesitter to a Neovim-0.11-compatible commit

**Important:** `nvim-treesitter` `main` dropped Neovim 0.11 support in commit `c82bf96f`
("feat!: drop support for Nvim 0.11"). Newer commits use `vim.list.unique`, which only
exists in Neovim 0.12+, and crash with:

```
attempt to index field 'list' (a nil value)
```

The `exe_dot_dev` branch's `lazy-lock.json` pins `nvim-treesitter` to commit `7caec274`
(the last 0.11-compatible commit). If you are setting this up from scratch on another
branch, ensure `lazy-lock.json` contains:

```json
"nvim-treesitter": { "branch": "main", "commit": "7caec274" },
```

When Neovim 0.12 is released and you upgrade, you can remove this pin and run `:Lazy update`.

---

## 8. Fix clangd fallbackFlags for C Compatibility (already done on `exe_dot_dev`)

The upstream `cpp.lua` sets `-std=c++20` which breaks C files. Already removed on this
branch. To replicate on another branch:

```bash
sed -i '/init_options = {/,/},/c\        -- No fallbackFlags — clangd auto-detects C vs C++.\n        -- For projects, use a compile_commands.json or .clangd file instead.' \
  ~/.config/nvim/lua/custom/plugins/cpp.lua
```

---

## 9. Quick Compile & Run Commands (already shipped as `run.lua`)

The branch already contains `lua/custom/plugins/run.lua` providing `:Run` and `:Runcpp`.

---

## 10. Install Plugins & Tools

Launch Neovim headlessly and let everything install. **Use `lazy-lock.json` so the
pinned `nvim-treesitter` commit is honored** — i.e. use `restore`, not `sync`, for the
first run on a fresh VM:

```bash
# Install plugins at the exact commits in lazy-lock.json (preserves the TS pin)
nvim --headless "+Lazy! restore" +qa

# Install Mason tools (clangd, clang-format, codelldb)
nvim --headless -c "MasonInstall clangd clang-format codelldb" -c "sleep 90" -c "qa"

# Install TreeSitter parsers (must be done via the Lua API on the main branch)
nvim --headless \
  -c "lua require('lazy').load({plugins={'nvim-treesitter'}})" \
  -c "lua require('nvim-treesitter').install({'c','cpp','cmake','bash','lua','luadoc','vim','vimdoc','markdown','markdown_inline','query','diff','html'}):wait(180000)" \
  -c "qa"
```

> Note: `:TSInstallSync` (used in older guides) does **not** exist on `nvim-treesitter`'s
> `main` branch — only `:TSInstall` and the Lua `install():wait()` API.

---

## 11. Verify Installation

```bash
# Check everything loads without errors
nvim --headless "+checkhealth" "+w! /tmp/health.txt" +qa
grep -E '✅|❌|⚠️' /tmp/health.txt | head -40

# Confirm parsers compiled
ls ~/.local/share/nvim/site/parser/ | sort
# Should include: c.so cpp.so cmake.so bash.so lua.so ...

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
| `nvim-treesitter` | Syntax highlighting for C/C++/CMake (pinned to 7caec274 for nvim 0.11) |

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
| `:Lazy sync` | Update all plugins (will move TS off the pin — see Step 7) |
| `:Lazy restore` | Revert plugins to `lazy-lock.json` (recommended on fresh VMs) |
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

### Error: `attempt to call field 'ge' (a nil value)` (in nvim-notify)

**Cause:** You are running Neovim 0.9.5 (the Ubuntu package) instead of 0.11.1.
The shell's command hash is pointing at `/usr/bin/nvim`.

**Fix:**
```bash
sudo apt remove -y neovim neovim-runtime
hash -r
nvim --version | head -1   # should now show 0.11.1
```

---

### Error: `attempt to index field 'list' (a nil value)` from `nvim-treesitter/config.lua`

**Cause:** A newer `nvim-treesitter` commit was checked out that requires Neovim 0.12.

**Fix:** Pin `nvim-treesitter` to commit `7caec274` (see Step 7) and run
`nvim --headless "+Lazy! restore" +qa`.

---

### Error: `Error during "tree-sitter build": ENOENT: no such file or directory: "tree-sitter"`

**Cause:** The `tree-sitter` CLI is missing from PATH. The `nvim-treesitter` `main` branch
compiles every parser from source and shells out to the CLI.

**Fix:** `npm install -g tree-sitter-cli --prefix ~/.local` (Step 3).

---

### Error: `Not an editor command: TSInstallSync`

**Cause:** `:TSInstallSync` was removed on the `main` branch of `nvim-treesitter`.

**Fix:** Use the Lua API:
```vim
:lua require('nvim-treesitter').install({'c','cpp','cmake'}):wait(180000)
```

---

### Error: `opt: expected table, got string` on startup

**Cause:** Running on Neovim < 0.11. See Step 2.

---

### Error: `fetch failed — Could not resolve host: github.com`

**Cause:** `:Lazy sync` fires 50+ parallel git fetches and overwhelms DNS.

**Fix:** `concurrency = 4` (Step 6) and the 8.8.8.8 fallback nameserver.

---

### Error: `Invalid argument '-std=c++20' not allowed with 'C'`

**Cause:** clangd `fallbackFlags` applied to `.c` files. **Fix:** see Step 8.

---

## One-Liner Setup (fresh VM)

Copy-paste this entire block on a fresh exe.dev VM:

```bash
set -e

# 1. Prereqs
sudo apt update && sudo apt install -y \
  git gcc g++ make cmake nodejs npm python3 python3-pip \
  ripgrep fd-find unzip curl xclip

# 2. Remove old nvim, install 0.11.1
sudo apt remove -y neovim neovim-runtime || true
curl -sLO https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz -C ~/
sudo ln -sf ~/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
hash -r

# 3. tree-sitter CLI
npm install -g tree-sitter-cli --prefix ~/.local

# 4. Clone config (exe_dot_dev branch already includes all patches + TS pin)
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
git clone -b exe_dot_dev https://github.com/aadehamid/kickstart.nvim.git ~/.config/nvim

# 5. Fallback DNS
grep -q '8.8.8.8' /etc/resolv.conf || sudo bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'

# 6. Install plugins (restore preserves the nvim-treesitter pin)
nvim --headless "+Lazy! restore" +qa
nvim --headless -c "MasonInstall clangd clang-format codelldb" -c "sleep 90" -c "qa"
nvim --headless \
  -c "lua require('lazy').load({plugins={'nvim-treesitter'}})" \
  -c "lua require('nvim-treesitter').install({'c','cpp','cmake','bash','lua','luadoc','vim','vimdoc','markdown','markdown_inline','query','diff','html'}):wait(180000)" \
  -c "qa"

echo "✅ Done! Run: nvim hello.c"
```
