# Neovim Plugin Cleanup (Phase 1 of 2)

## Context

The Neovim config (`neovim/`) is a ~90-plugin `vim-plug` setup descended from an old Janus-style dotfiles skeleton, with a handful of modern Lua plugins (avante.nvim, mcphub.nvim, snacks.nvim) layered on top later. Investigation surfaced:

- ~20+ plugin config files (`neovim/config/**/*.vim`) for plugins that are commented out or fully removed from `neovim/plug.vim` — dead weight left behind by past cleanups.
- An AI-assistant plugin block (avante.nvim, mcphub.nvim, copilot.lua, plus their exclusive dependencies) added in a prior session but never actually needed once the tmux + Claude Code CLI workflow is fixed up.
- A believed "coc.nvim vs ale overlap" that turned out to be an intentional, currently-working feature (`coc-settings.json`'s `diagnostic.displayByAle`), not a real conflict.
- Several plugins disabled with no recorded reason, some of which are worth reviving now (multi-cursor support, prose-writing mode, indent guides via a modern replacement).

This is Phase 1 of a two-phase project. **Phase 1 (this spec) makes no changes to the LSP/completion engine** — coc.nvim, ale, and vim-plug all stay. Phase 2 (replacing vim-plug/coc.nvim/ale with Neovim's built-in `vim.pack` plugin manager + native `vim.lsp` + `mason.nvim` + `blink.cmp`, following the `kickstart.nvim` pattern) is a separate, future design, motivated by durability and reduced third-party dependency — not addressed further here.

## Goals

- Reduce the number of plugins and config files actually being managed, without adding new ongoing maintenance burden.
- Remove plugins/dependencies that no longer have a reason to exist (superseded, or added for a feature that's being dropped).
- Fix or replace the small number of plugins that were disabled by a bug rather than by choice.
- Revive a few previously-abandoned, low-risk features the user actually wants (multi-cursor, prose mode, indent guides).
- Leave the coc.nvim/ale diagnostic pipeline untouched — it already works as intended.

## Non-goals

- No change to the plugin manager (`vim-plug` stays for this phase).
- No change to the LSP/completion engine (`coc.nvim` stays; `ale` stays exactly as configured for fixing + diagnostic display).
- No attempt to evaluate or adopt native Neovim LSP, `blink.cmp`, or `mason.nvim` — that is Phase 2.

## Changes

### 1. Delete dead/orphaned plugin config files

Each of these corresponds to a plugin that is either fully absent from `plug.vim` or commented out there, confirmed by cross-referencing every non-commented `Plug`/`Plugged()` call (and explicit `source` line) against every file under `neovim/config/`:

- `config/ack.vim` — superseded by `fzf.vim`'s ag/rg search
- `config/chauncey-garrett/vim-plist.vim` — superseded by `darfink/vim-plist` (active)
- `config/ctrl-p.vim` — superseded by `fzf.vim`
- `config/ervandew/supertab.vim` — superseded by coc.nvim's own tab-completion
- `config/fatih/vim-go.vim` — superseded by the `coc-go` extension
- `config/iCyMind/NeoSolarized.vim` — superseded by `lifepillar/vim-solarized8` (active)
- `config/junegunn/gundo.vim` — stray duplicate; the real config is `config/sjl/gundo.vim.vim` (active)
- `config/neocomplete.vim` — superseded by coc.nvim
- `config/neomake/neomake.vim` — superseded by `ale`
- `config/SirVer/ultisnips.vim` — superseded by the `coc-snippets` extension (see item 6)
- `config/syntastic.vim` — superseded by `ale`
- `config/tpope/surround.vim` — superseded by `machakann/vim-sandwich`, which already loads a `vim-surround`-compatible keymap layer (`runtime macros/sandwich/keymap/surround.vim` in `plug.vim`); confirmed via git history (disabled 2017-08-18, sandwich keymaps fixed up 2018-09-26) that this was a deliberate, long-standing, working swap — no functionality lost.
- `config/Valloric/YouCompleteMe.vim` — superseded by coc.nvim entirely
- `config/terryma/vim-multiple-cursors.vim` — superseded by the new `vim-visual-multi` addition (item 4)
- `config/Yggdroot/indentLine.vim` — disabled due to a documented conflict with vim-markdown; superseded by a modern replacement (item 4)
- `config/tmuxline.vim` — no recorded reason for disabling, not selected for revival
- `config/mhinz/vim-startify.vim` — superseded by `snacks.dashboard` (item 3)

### 2. Remove the AI plugin block entirely

Drop `avante.nvim` and `mcphub.nvim` (no longer needed — see rationale below) plus every dependency that was added *only* for their sake, verified by grep to have no other consumer in this config:

- `yetone/avante.nvim`
- `ravitemer/mcphub.nvim`
- `zbirenbaum/copilot.lua`
- `MunifTanjim/nui.nvim`
- `MeanderingProgrammer/render-markdown.nvim`
- `hrsh7th/nvim-cmp`
- `HakonHarnes/img-clip.nvim`
- `stevearc/dressing.nvim`
- `nvim-lua/plenary.nvim`
- `nvim-tree/nvim-web-devicons` (icon needs remain covered by the already-active `ryanoasis/vim-devicons`)

Delete their corresponding config files too (several are already empty/inert: `yetone/avante.nvim.vim`, `hrsh7th/nvim-cmp.vim`, `zbirenbaum/copilot.lua.vim`).

**Rationale:** the user runs Claude Code via the CLI in tmux already. The one real gap — buffers not auto-reloading after Claude edits a file in a sibling pane — is fixed by item 5 (tmux `focus-events`) using the already-installed `wincent/terminus`, not by adding editor-side AI plugins. avante.nvim's only remaining edge (staying in-buffer instead of glancing at a tmux pane) was judged not worth the added maintenance surface.

### 3. Keep `folke/snacks.nvim`, repurposed

Originally added only as an avante.nvim input-UI dependency (and never actually initialized — no `require('snacks').setup()` call exists today). Instead of removing it, configure it for its own sake:

- `dashboard` module, replacing `vim-startify`
- `notify` module, for nicer floating notifications

No other snacks modules (terminal, picker, zen, etc.) are in scope for this phase.

### 4. Add two new plugins

- `mg979/vim-visual-multi` — multi-cursor editing. (Currently there is no working multi-cursor support at all: `terryma/vim-multiple-cursors` is disabled and coc.nvim's own `coc-cursors` keymaps are commented out in `coc.vim`. User chose a standalone modern plugin over wiring up `coc-cursors`.)
- One of `lukas-reineke/indent-blankline.nvim` (established standard) or `saghen/blink.indent` (newer, higher-performance, same author as blink.cmp) for indent guides, replacing `Yggdroot/indentLine`. Exact pick deferred to the implementation plan.

### 5. Re-enable previously-disabled plugins with no code changes needed

Uncomment in `plug.vim`; config files already exist and there is no recorded reason to believe any of these were broken (unlike `indentLine`, which had a documented conflict and is being replaced instead, not just re-enabled):

- `junegunn/vim-emoji` — its blocker (YouCompleteMe integration) no longer applies since YCM is gone.
- `go2null/Mark--Karkat` — multi-pattern highlighting; no recorded reason for the disable.
- `romainl/vim-qf` — quickfix list enhancements; no recorded reason for the disable.
- `tiagofumo/vim-nerdtree-syntax-highlight` — NERDTree filename coloring by type. Note: has had reported contrast issues with Solarized colorschemes historically; the user runs `vim-solarized8`, so this should be visually checked after enabling, not assumed broken if it looks off.
- `reedes/vim-thematic`, `reedes/vim-pencil`, `reedes/vim-colors-pencil` — distraction-free prose-writing mode, pairing with the already-active `reedes/vim-wordy`/`reedes/vim-lexical`. The dead `config/reedes/colors-pencil.vim` file gets reconciled/renamed to match the `vim-colors-pencil` plugin name rather than deleted.

### 6. Leave the coc.nvim/ale diagnostic pipeline untouched

`neovim/coc-settings.json` sets `"diagnostic": { "displayByAle": true }`, confirmed active in the installed coc.nvim build (`neovim/plugged/coc.nvim/build/index.js`): coc computes diagnostics from real language servers (including custom `languageserver` entries for `terraform-ls` and `docker-langserver` already configured there) and suppresses its own rendering in favor of ale's sign column/loclist/airline integration. `ale` itself (now maintained under `dense-analysis/ale`) is confirmed still actively maintained and explicitly designed to coexist with LSP-based diagnostics. **No changes needed here** — this was investigated as a possible "overlap to resolve" and turned out to be an intentional, correctly-working integration.

`chauncey-garrett/vim-snippets` should be verified to still expand correctly via the `coc-snippets` extension (already in `coc_global_extensions`) now that `SirVer/ultisnips` is being dropped — no code change expected, just a runtime check.

### 7. tmux fix

Add to `tmux/tmux.conf`:
```tmux
set -g focus-events on
```
This lets tmux forward terminal focus-change events across pane switches to the already-installed `wincent/terminus`, which in turn fires `:checktime` on `FocusGained` — so switching back to the Neovim pane after Claude Code edits a file in a sibling pane auto-reloads the buffer, using `'autoread'` which is already set.

## Verification

- `nvim --headless -c 'quit'` exits cleanly with no missing-file/missing-plugin errors after the `plug.vim` edits.
- `:PlugStatus` shows exactly the intended trimmed-and-adjusted plugin list, no orphaned entries.
- Open a `.tf` file: confirm coc-driven diagnostics still render (via ale's UI) and `ale_fix_on_save` still runs `terraform fmt`.
- Confirm the snacks dashboard appears on a bare `nvim` launch (no file arg) and `vim-startify` is gone.
- Confirm multi-cursor editing works via `vim-visual-multi`'s default keybindings.
- Confirm indent guides render via the new plugin with no vim-markdown conflict.
- Confirm `vim-emoji`, `Mark--Karkat`, `vim-qf`, and `vim-nerdtree-syntax-highlight` load without error; visually check NERDTree syntax highlighting against the Solarized theme.
- Expand a snippet from `vim-snippets` and confirm it still works via `coc-snippets`.
- Edit a file from a second tmux pane, switch back to the Neovim pane, confirm it auto-reloads.

## Deferred to Phase 2 (separate future design)

Replace `vim-plug` with Neovim's built-in `vim.pack` plugin manager; replace `coc.nvim` + `ale` with native `vim.lsp.enable(...)` + `mason.nvim` (server installation) + `blink.cmp` (completion UI) + a snippet engine, following the `kickstart.nvim` template pattern. Motivated by reducing dependence on third-party frameworks in favor of Neovim core APIs. Not started; scope and effort not yet estimated.
