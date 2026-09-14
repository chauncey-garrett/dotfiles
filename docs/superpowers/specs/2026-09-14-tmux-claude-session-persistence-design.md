# Tmux + Claude Code Session Persistence

## Context

macOS reboots/crashes have wiped Chauncey's tmux server three times now (~2026-07-30,
~2026-08-08, ~2026-08-10), each time losing track of every open tmux window and the
Claude Code conversation running in it. There is no tmux-resurrect/continuum installed,
so recovery has been purely forensic: find `~/.claude/projects/**/*.jsonl` files whose
mtime clusters tightly around the crash moment, infer directories from the transcript's
last recorded `cwd`, and manually `claude -r <uuid>` each one back into a new window.

That method has a structural blind spot, confirmed directly during the 2026-08-10
recovery: it only finds sessions that had an active write at the exact moment of the
crash. A pane that's been open and idle for hours or days (very much Chauncey's normal
usage — a `claude` session left running in a window for a long-lived task) produces no
new jsonl write on crash, so it's invisible to mtime clustering. Cross-checking the
2026-07-30 recovery's 14-session list against current file mtimes found 8 of those 14
untouched since the day they were recovered — no way to tell, from the filesystem alone,
whether they were deliberately closed or are still open and simply idle.

Chauncey's dotfiles (`~/.dotfiles`) already wire up TPM
(`tmux/config/tmux-plugins/tmux-tpm.conf`), but no actual plugins are installed through it
yet beyond TPM itself.

## Goals

- Never again lose track of *which tmux windows existed* after a crash, including windows
  that were idle at crash time.
- Automatically resume the right Claude Code conversation in each restored window, without
  relying on Chauncey having typed an explicit `-r`/`-c` flag when he originally opened it.
- Fit the existing dotfiles conventions: TPM-managed, one config file per plugin under
  `tmux/config/tmux-plugins/`.

## Non-goals

- Perfect disambiguation when multiple panes share the *exact same literal directory*
  simultaneously (e.g. three windows all plainly in `~/dev`). Accepted as a known, rare
  edge case — see Known limitations.
- Restoring non-Claude long-running programs (k9s, ssh, gcloud, etc.). Only `claude` panes
  are in scope; the mechanism generalizes trivially later if wanted.
- Multi-worktree-of-one-repo disambiguation needs no special handling — Claude Code keys
  conversation history by literal absolute directory, and each worktree is already a
  distinct path, confirmed directly from this session's own investigation (the migration-
  assessment repo and its `.claude/worktrees/research+ci-tooling-comparison-prompt` worktree
  produced two different project folders under `~/.claude/projects/`).

## Changes

### 1. Add `tmux-plugins/tmux-resurrect.conf`

```tmux
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-processes '"~claude->claude --continue"'
```

`@resurrect-processes` controls which foreground pane commands get relaunched on restore
(tmux-resurrect always restores pane layout + cwd regardless; this only concerns whether
the *program* running in the pane gets relaunched). The `~` prefix means substring-match
"claude" against the pane's actual running command line. The `->claude --continue`
template means: **regardless of what arguments that pane's `claude` was originally invoked
with**, always restore it as `claude --continue`. This is deliberate, not an oversight —
Chauncey's normal pattern is to open a bare `claude` in a window and leave it running for
days, so the process's argv never changes to reflect however deep the conversation gets.
Preserving the original argv (the `*` placeholder instead) would just replay `claude`
verbatim most of the time, starting a blank session instead of resuming. Always appending
`--continue` self-heals this: it resumes the most recent conversation for that pane's
(also-restored) working directory, no matter how the pane was originally launched.

### 2. Add `tmux-plugins/tmux-continuum.conf`

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-save-interval '5'
set -g @continuum-restore 'on'
```

- `@continuum-save-interval '5'` — autosave every 5 minutes (tighter than the plugin's
  15-minute default) via a status-bar hook. This is what closes the idle-pane blind spot:
  the save is a point-in-time snapshot of pane layout/cwd/command, independent of whether
  anything happened recently in that pane.
- `@continuum-restore 'on'` — restore automatically within ~10s of the first tmux server
  start after a crash/reboot, no manual step required. Since restore only replays
  `claude --continue` (no injected message), each pane reopens at its own idle prompt
  exactly like a manual resume — no autonomous-action risk beyond what a normal resume
  already carries.

### 3. Wire both into `tmux.conf`

Add both `source` lines next to the existing plugin sources, **above** the
`tmux-plugins/tmux-tpm.conf` line (TPM's own line — `run-shell -b
'~/.dotfiles/tmux/plugins/tpm/tpm'` — must stay the last line in the file, per TPM's own
requirement and the existing `# NOTE: Keep this line at the very bottom of tmux.conf`
comment already in `tmux-tpm.conf`).

### 4. Install

TPM auto-installs missing plugins the next time tmux starts (the existing `if "test ! -d
... tpm"` bootstrap clones TPM itself the same way). No separate install step beyond
starting/reloading tmux; `prefix + I` also force-installs if needed.

## Known limitations

- **Same-directory multi-pane ambiguity.** If two or more panes are simultaneously sitting
  in the exact same literal directory, `--continue`'s "most recent conversation in this
  directory" can only pick one — a restore might resume the wrong one of the pair.
  Accepted tradeoff (Chauncey's choice): notice the wrong context, run
  `claude -r <correct-uuid>` manually. A full fix would need a background `lsof`-based
  pane→session-uuid tracker hooked into resurrect's save/restore hooks — deliberately not
  built; see the dotfiles todo for the reasoning if this needs revisiting.
- **Deleted worktrees.** If a `.claude/worktrees/...` directory is removed between a save
  and a later restore, that pane's `cd` fails and `claude --continue` never runs — visible
  as a shell error in that pane, not a silent failure.
- **First-run folder-trust prompt.** A directory Claude Code hasn't trust-prompted in this
  exact context before will pause on "Do you trust this folder?" instead of resuming;
  harmless, needs one keypress.
- **Restore fires on any tmux server start, not just crash-triggered ones.** A deliberate
  `tmux kill-server` also triggers auto-restore on the next `tmux` start. Escape hatch:
  `touch ~/tmux_no_auto_restore` before restarting tmux when a clean slate is wanted.

## Validation plan

Config review alone doesn't prove this works — validate end-to-end before trusting it:

1. Confirm both plugins install cleanly via TPM (`prefix + I`, then check
   `~/.dotfiles/tmux/plugins/tmux-resurrect` and `tmux-continuum` exist).
2. Manually trigger a save (`prefix + ctrl-s`) with at least one real `claude` pane open.
3. Deliberately `tmux kill-server`.
4. Start a fresh `tmux`.
5. Confirm: session/window/pane layout matches, each pane's cwd is correct, and each
   `claude` pane actually launched `claude --continue` and landed on the right
   conversation (not a blank new session).
