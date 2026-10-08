# Tmux + Claude Code Session Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make tmux automatically survive a reboot/crash with every window's Claude Code conversation resumed, by adding tmux-resurrect + tmux-continuum to the existing TPM-managed dotfiles tmux config.

**Architecture:** Two new one-plugin-per-file configs (matching the existing `tmux/config/tmux-plugins/*.conf` convention) declare the plugins and their options; `tmux.conf` sources both above TPM's bottom-anchor line. `@resurrect-processes` is configured to always restore any `claude` pane as `claude --continue`, regardless of what arguments it originally launched with, so long-lived idle panes (the actual failure mode we're fixing) still resume correctly. `@continuum-save-interval '5'` + `@continuum-restore 'on'` make this fully automatic — no manual save or restore step.

**Tech Stack:** tmux, TPM (tmux-plugins/tpm, already installed), tmux-resurrect, tmux-continuum, zsh.

**Spec:** `/Users/chaunceygarrett/.dotfiles/docs/superpowers/specs/2026-09-14-tmux-claude-session-persistence-design.md`

## Global Constraints

- TPM's own `run-shell -b '~/.dotfiles/tmux/plugins/tpm/tpm'` line must remain the **last** line in `tmux.conf` — do not add anything after it.
- `tmux/.gitignore` already ignores the whole `plugins` directory — installed plugin code (TPM clones of tmux-resurrect/tmux-continuum) is **never** committed; only the two new `.conf` files and the `tmux.conf` edit are committed.
- Do not touch or stage the pre-existing uncommitted `zsh/zshrc` change — unrelated, not part of this work. Stage files by exact path, never `git add -A` or `git add .`.
- Repo is `~/.dotfiles`, current branch `ohmyzsh` (tracks `origin/ohmyzsh`) — commit there, do not create or switch branches.
- **Never run `tmux kill-server` against the user's real `prezto!` session** — it may contain the live Claude Code conversation driving this very work. All kill-server/restore rehearsal in Task 3 happens on an isolated throwaway tmux server (`tmux -L persistence-test ...`), never the default socket.
- `@resurrect-processes` value must be exactly `'"~claude->claude --continue"'` (note the nested quoting: single-quotes for the tmux `set` value, double-quotes inside for the resurrect sub-syntax) — this is the self-healing behavior the whole design depends on; do not simplify it to `'claude'` or drop the `--continue` template.

---

### Task 1: Add plugin config files and wire them into `tmux.conf`

**Files:**
- Create: `/Users/chaunceygarrett/.dotfiles/tmux/config/tmux-plugins/tmux-resurrect.conf`
- Create: `/Users/chaunceygarrett/.dotfiles/tmux/config/tmux-plugins/tmux-continuum.conf`
- Modify: `/Users/chaunceygarrett/.dotfiles/tmux/tmux.conf:33` and `:36-37`

**Interfaces:**
- Produces: two `@plugin` declarations TPM will discover on next install (`tmux-plugins/tmux-resurrect`, `tmux-plugins/tmux-continuum`), and the `@resurrect-processes`/`@continuum-save-interval`/`@continuum-restore` options Task 3's rehearsal depends on.

- [ ] **Step 1: Create `tmux-resurrect.conf`**

```tmux
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-processes '"~claude->claude --continue"'
```

- [ ] **Step 2: Create `tmux-continuum.conf`**

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-save-interval '5'
set -g @continuum-restore 'on'
```

- [ ] **Step 3: Wire `tmux-continuum.conf` into `tmux.conf`, alphabetically before `tmux-copycat.conf`**

Current `tmux.conf` line 33 is:
```tmux
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-copycat.conf
```
Change it to:
```tmux
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-continuum.conf
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-copycat.conf
```

- [ ] **Step 4: Wire `tmux-resurrect.conf` into `tmux.conf`, alphabetically between `tmux-pain-control.conf` and `tmux-sidebar.conf`**

Current `tmux.conf` lines 36-37 are:
```tmux
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-pain-control.conf
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-sidebar.conf
```
Change to:
```tmux
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-pain-control.conf
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-resurrect.conf
source ~/.dotfiles/tmux/config/tmux-plugins/tmux-sidebar.conf
```

- [ ] **Step 5: Verify the config parses with no syntax errors, on an isolated test server (not the real session)**

```bash
tmux -L persistence-test-syntax new-session -d -s check \; \
  source-file ~/.dotfiles/tmux/tmux.conf \; \
  show-options -g | grep -E '@resurrect-processes|@continuum-save-interval|@continuum-restore'
tmux -L persistence-test-syntax kill-server
```
Expected: no error output from `source-file`, and the grep prints all three lines, e.g.:
```
@resurrect-processes "~claude->claude --continue"
@continuum-save-interval 5
@continuum-restore on
```
(`@plugin` lines don't show in `show-options` — TPM reads those directly from the sourced files — so this check only confirms the option *values*, which is sufficient proof the new files parsed without error.)

- [ ] **Step 6: Commit**

```bash
cd ~/.dotfiles
git add tmux/config/tmux-plugins/tmux-resurrect.conf tmux/config/tmux-plugins/tmux-continuum.conf tmux/tmux.conf
git status --short   # confirm only these 3 files are staged — zsh/zshrc must NOT appear
git commit -m "$(cat <<'EOF'
Add tmux-resurrect + tmux-continuum for crash-proof session recovery

Three reboot-induced crashes have wiped tmux state with no way to tell
which windows/panes were open, since forensic jsonl-mtime reconstruction
is blind to panes that were idle at crash time. Continuum's periodic
save closes that gap; @resurrect-processes is configured to always
restore any claude pane as `claude --continue` regardless of its
original invocation, since panes are typically left running for days
without retyping the launch command.

Spec: docs/superpowers/specs/2026-09-14-tmux-claude-session-persistence-design.md

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Install the plugins via TPM and verify

**Files:** none (installs into `tmux/plugins/`, which is gitignored — nothing to commit from this task).

**Interfaces:**
- Consumes: the `@plugin` lines from Task 1's two new `.conf` files.
- Produces: `~/.dotfiles/tmux/plugins/tmux-resurrect/` and `~/.dotfiles/tmux/plugins/tmux-continuum/` on disk, which Task 3's rehearsal depends on existing.

- [ ] **Step 1: Confirm the plugins are not already installed (baseline)**

```bash
ls ~/.dotfiles/tmux/plugins/ 2>/dev/null | grep -E 'tmux-resurrect|tmux-continuum'
```
Expected: no output (neither directory exists yet).

- [ ] **Step 2: Run TPM's own install script directly (scriptable equivalent of pressing `prefix + I`)**

```bash
~/.dotfiles/tmux/plugins/tpm/bin/install_plugins
```
Expected: output mentioning cloning `tmux-plugins/tmux-resurrect` and `tmux-plugins/tmux-continuum` (TPM skips plugins already installed, so this is safe to re-run).

- [ ] **Step 3: Verify both plugin directories now exist and are non-empty**

```bash
ls ~/.dotfiles/tmux/plugins/tmux-resurrect/resurrect.tmux
ls ~/.dotfiles/tmux/plugins/tmux-continuum/continuum.tmux
```
Expected: both files exist (these are each plugin's TPM entry-point script — their presence confirms a real, complete clone, not a partial/failed one).

---

### Task 3: End-to-end crash/restore rehearsal on an isolated test server

**Files:** none — this is a behavioral validation task, no file changes.

**Interfaces:**
- Consumes: the installed plugins from Task 2 and the config from Task 1.
- Produces: a pass/fail verdict on the actual spec goal (not just config review). If this fails, do not consider the plan done — debug and fix before reporting completion.

**Why an isolated server:** this rehearsal deliberately kills a tmux server to prove restore works. The user's real session is named `prezto!` on the default socket and may contain the live Claude Code conversation executing this very plan. Every command in this task targets a separate named socket (`-L persistence-test`) so the real session is never touched.

- [ ] **Step 1: Start the isolated test server with two windows — one plain, one running `claude`**

```bash
tmux -L persistence-test new-session -d -s restoretest -n shell -c /tmp
tmux -L persistence-test source-file ~/.dotfiles/tmux/tmux.conf
tmux -L persistence-test new-window -t restoretest -n claudepane -c /tmp
tmux -L persistence-test send-keys -t restoretest:claudepane "claude" Enter
```
Wait for the prezto shell init race documented in `~/.claude/projects/-Users-chaunceygarrett-dev/memory/reference_tmux_claude_session_recovery.md` (poll `pane_current_command`, don't just sleep a fixed time):
```bash
for attempt in $(seq 1 40); do
  cmd=$(tmux -L persistence-test display-message -p -t restoretest:claudepane '#{pane_current_command}')
  [ "$cmd" != "zsh" ] && [ -n "$cmd" ] && break
  sleep 0.5
done
tmux -L persistence-test display-message -p -t restoretest:claudepane '#{pane_current_command}'
```
Expected: a claude version string (not `zsh`), confirming claude actually launched in that pane.

- [ ] **Step 2: Record the baseline layout for later comparison**

```bash
tmux -L persistence-test list-windows -t restoretest -F '#{window_index}:#{window_name} #{pane_current_path} #{pane_current_command}' \
  | tee /private/tmp/claude-502/-Users-chaunceygarrett-dev/5b04030d-c9c9-4ad9-8af6-6afd093e8000/scratchpad/persistence-test-baseline.txt
```
Expected: two lines, one per window, each showing `/tmp` as the path and `shell`/`claude`-version as the respective commands.

- [ ] **Step 3: Trigger a manual resurrect save (don't wait for the 5-minute timer)**

```bash
tmux -L persistence-test run-shell '~/.dotfiles/tmux/plugins/tmux-resurrect/scripts/save.sh'

# The save directory is NOT unconditionally ~/.tmux/resurrect — helpers.sh uses that path
# only if it already exists, and otherwise falls back to
# ${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect. See the `last`-symlink bullet in the
# spec's Known limitations. Resolve it instead of assuming:
resurrect_dir=~/.tmux/resurrect
[ -d "$resurrect_dir" ] || resurrect_dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
ls -la "$resurrect_dir/last" "$resurrect_dir"/tmux_resurrect_*.txt
```
Expected: `$resurrect_dir/last` is a symlink to a freshly-timestamped `tmux_resurrect_*.txt` file (resurrect's save format is server-agnostic — it's keyed by the resolved resurrect directory, not by socket name, so this file is what this task's restore step reads regardless of which tmux server does the restoring — and equally, what the *real* session would read, which is why the spec warns against saving over it during a rehearsal).

- [ ] **Step 4: Deliberately kill the isolated test server (NOT the real session)**

```bash
tmux -L persistence-test kill-server
tmux -L persistence-test list-sessions 2>&1
```
Expected: the `list-sessions` call errors with "no server running on persistence-test" — confirming the test server is actually gone (and implicitly, that we killed the right one — if this instead printed a session list, STOP, something is wrong with the socket name, and do not proceed to Step 5).

- [ ] **Step 5: Start a fresh isolated server and let continuum auto-restore**

```bash
tmux -L persistence-test new-session -d -s bootstrap
tmux -L persistence-test source-file ~/.dotfiles/tmux/tmux.conf
sleep 12   # @continuum-restore-max-delay default is 10s; give it margin
```

- [ ] **Step 6: Compare restored layout against the Step 2 baseline**

```bash
tmux -L persistence-test list-windows -t restoretest -F '#{window_index}:#{window_name} #{pane_current_path} #{pane_current_command}' \
  | diff /private/tmp/claude-502/-Users-chaunceygarrett-dev/5b04030d-c9c9-4ad9-8af6-6afd093e8000/scratchpad/persistence-test-baseline.txt -
```
Expected: no diff output for window name and path columns. The `pane_current_command` column for `claudepane` may legitimately differ in its exact version string across the two captures (that's fine) but must still be a claude version, not `zsh` or empty — check that explicitly:
```bash
tmux -L persistence-test display-message -p -t restoretest:claudepane '#{pane_current_command}'
```
Expected: a claude version string, same as Step 1.

- [ ] **Step 7: Confirm the restored claude pane actually resumed a conversation (not a blank new session)**

```bash
tmux -L persistence-test capture-pane -p -t restoretest:claudepane | grep -v '^[[:space:]]*$' | tail -10
```
Expected: pane content showing an existing conversation's idle prompt (e.g. a `recap:`/`✻` status line or prior message history), **not** the first-launch "Welcome to Claude Code" / empty-state screen — the latter would mean `--continue` started fresh instead of resuming, which means Task 1's `@resurrect-processes` value is wrong and must be fixed before this plan is done.

- [ ] **Step 8: Clean up the isolated test server**

```bash
tmux -L persistence-test kill-server 2>&1
rm -f /private/tmp/claude-502/-Users-chaunceygarrett-dev/5b04030d-c9c9-4ad9-8af6-6afd093e8000/scratchpad/persistence-test-baseline.txt
```

- [ ] **Step 9: Report the verdict**

Summarize pass/fail for each of: layout restored, cwd restored, claude pane relaunched, claude pane resumed (not blank). If all four pass, the implementation is complete. If any failed, fix the relevant config (Task 1) or installation (Task 2) and re-run this task from Step 1 — do not report the plan done on a partial pass.
