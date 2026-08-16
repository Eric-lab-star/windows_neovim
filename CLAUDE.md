# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Neovim configuration shared between a macOS machine and a Windows machine via this git
repository. Both machines clone the same repo; there is no per-machine branch. Anything that
differs between the two must be resolved **at runtime in Lua**, not by editing one machine's copy.

Config location per OS:

| OS | Path |
|---|---|
| macOS | `~/.config/nvim` |
| Windows | `%LOCALAPPDATA%\nvim` (unless `XDG_CONFIG_HOME` is set) |

## Layout

```
init.lua              →  require("config.lazy") and nothing else
lua/config/lazy.lua      lazy.nvim bootstrap, options, langmap, global keymaps, LSP keymaps
lua/config/cppbuild.lua  C/C++ build & run (<Space>), CMakeLists.txt scaffolding
lua/plugins/*.lua        one file per plugin; lazy.nvim auto-imports the whole directory
lazy-lock.json           plugin versions — tracked on purpose, see below
after/, ftplugin/, jdtls/
```

Adding a plugin means adding a file under `lua/plugins/`. There is no central list to register
it in — `{ import = "plugins" }` in `lazy.lua` picks it up.

## Cross-machine rules

These are the rules that keep one repo working on both machines. Breaking them doesn't fail on
the machine you're editing from — it fails silently on the other one.

- **No absolute paths that only exist on one OS.** Use `vim.fn.expand("~/...")` for home-relative
  paths, or branch on `vim.fn.has("mac")` / `vim.fn.has("win32")`. `lua/plugins/lsp.lua`
  (`arduino_cli_config`) is the reference example.
- **Tool paths must degrade to a bare command name.** The pattern used throughout: probe a
  known install location, then fall back to the name so `$PATH` resolves it. See `clangd_path()`
  in `lsp.lua`, `lldb_dap_path()` in `dap.lua`, `clangformat()` in `formatter.lua`. A hardcoded
  macOS-only fallback is a bug — it produces a confusing "not found" on Windows.
- **`lazy-lock.json` is committed.** It pins plugin commits so both machines run identical
  plugin versions. Commit it whenever `:Lazy sync` changes it; don't gitignore it.
- **Commit and push before switching machines.** This repo drifted ~10 months once and the two
  machines diverged badly. The config only syncs as often as it is pushed.

## Conventions

- Tabs for indentation, not spaces.
- Comments are in Korean and explain *why*, including the trap being avoided. Match that style —
  a comment restating what the line does adds nothing here.
- Every keymap gets a `desc`. which-key renders `desc` verbatim; without it the raw command
  string is shown instead.
- Leader is `\` (`vim.g.mapleader`).

## Keymaps worth knowing

- `<Space>` (c/cpp buffers) — save, configure if needed, build, run. `:CppTarget` re-picks the
  executable when a project has several.
- `\?` / `\K` — which-key: buffer-local / global keymap list.
- `<F5>`, `<F10>`, `<F11>`, `<F12>` — DAP continue / step over / into / out. `\d*` for
  breakpoints and UI.
- `gd`, `gD` are mapped to LSP definition/declaration. Rename, code action, references,
  implementation and type-definition are **not** mapped here — Neovim 0.11+ provides
  `grn`, `gra`, `grr`, `gri`, `grt` by default. Do not map bare `gr`; it hijacks that whole
  prefix and delays every `gr*` key by `timeoutlen`.

## C/C++ projects

`lua/config/cppbuild.lua` generates a `CMakeLists.txt` for projects that lack one. When changing
that template, keep it in sync with what the generated projects expect:

- `-std=c++20` with `CMAKE_CXX_EXTENSIONS OFF` (not `gnu++20`)
- warnings: `-Wall -Weffc++ -Wextra -Wconversion -Wsign-conversion -Werror -g`, grouped into a
  `PROJECT_WARNINGS` variable so extra targets can reuse it
- `-Weffc++` is a no-op under Apple Clang; it is kept for GCC builds
- executables go to `build/bin/` via `CMAKE_RUNTIME_OUTPUT_DIRECTORY` passed on the configure
  command line — the debugger and `<Space>` both assume that location
- sources are listed explicitly; `file(GLOB)` is avoided because it doesn't trigger re-configure
