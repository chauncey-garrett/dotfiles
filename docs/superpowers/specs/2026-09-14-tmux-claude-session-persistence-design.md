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
set -g @resurrect-processes '"~claude->claude --continue"'

set -g @plugin 'tmux-plugins/tmux-resurrect'
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
set -g status-interval 60

set -g @continuum-save-interval '5'
set -g @continuum-restore 'on'

set -g @plugin 'tmux-plugins/tmux-continuum'
```

- `status-interval 60` — **load-bearing, not boilerplate.** Continuum implements autosave
  as a `#(…/continuum_save.sh)` interpolation prepended to `status-right`, so the save
  timer only advances when the status line redraws. The existing
  `tmux/config/tmux-powerline.conf` sets `status-interval 0`, which disables those redraws
  entirely — leaving the autosave hook installed but permanently frozen on an idle session,
  which is precisely the failure mode this whole design exists to fix. `tmux.conf` sources
  `tmux-continuum.conf` after `tmux-powerline.conf`, so this re-enables redraws (and
  therefore the save timer) without editing the powerline config.
- `@continuum-save-interval '5'` — autosave every 5 minutes (tighter than the plugin's
  15-minute default) via that status-bar hook. This is what closes the idle-pane blind spot:
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
- **`~claude` matches the whole saved command line, not just the program name.** The `~`
  prefix in `@resurrect-processes` is a plain substring test against the pane's entire
  saved command line — arguments and paths included — so any pane whose command line merely
  *mentions* a path containing "claude" is rewritten to `claude --continue` on restore.
  `vim ~/.claude/CLAUDE.md`, `tail -f ~/.claude/logs/app.log`, and
  `less ~/.dotfiles/.claude/settings.json` all match, and all come back as a Claude Code
  session instead of the program that was actually running. Impact is annoyance, not
  danger: the restored pane sits at an idle prompt and takes no autonomous action, so the
  cost is noticing and relaunching the original command by hand. Narrowing the pattern is
  **not** the fix — `~claude` is also what correctly matches the real CLI when it reports
  itself as `node …/claude-code/cli.js`, which some install configurations produce, so a
  stricter program-name match would break the feature's main case to avoid a cosmetic one.
  Documented rather than "fixed".
- **Deleted worktrees.** If a `.claude/worktrees/...` directory is removed between a save
  and a later restore, that pane's `cd` fails and `claude --continue` never runs — visible
  as a shell error in that pane, not a silent failure.
- **First-run folder-trust prompt.** A directory Claude Code hasn't trust-prompted in this
  exact context before will pause on "Do you trust this folder?" instead of resuming;
  harmless, needs one keypress.
- **Restore fires on any tmux server start, not just crash-triggered ones.** A deliberate
  `tmux kill-server` also triggers auto-restore on the next `tmux` start. Escape hatch:
  `touch ~/tmux_no_auto_restore` before restarting tmux when a clean slate is wanted.
- **Auto-restore never fires while any other tmux server (any socket) is already running.**
  Confirmed during implementation (`tmux-continuum/docs/multiple_tmux_servers.md`):
  `another_tmux_server_running_on_startup()` counts all `tmux` processes for the user via
  `ps`, with no socket-name awareness, and the upstream doc describes the policy as "giving
  precedence to the tmux server that was first started" — no config option overrides this.
  Irrelevant to the real crash/reboot scenario (zero other servers exist at boot), but means
  any *manual* rehearsal of this feature from inside an already-running tmux session (e.g.
  one hosting a Claude Code CLI session) must invoke `tmux-resurrect/scripts/restore.sh`
  directly rather than waiting for continuum's background auto-trigger, which is
  structurally unobservable in that situation.

  **The same gate also decides whether autosave gets installed at all** — this is an
  ongoing-operation concern, not just a boot-time one. `continuum.tmux`'s `main()` calls
  `add_resurrect_save_interpolation` (the function that prepends the
  `#(…/continuum_save.sh)` hook to `status-right`) only `if ! another_tmux_server_running`
  — the sibling of the `_on_startup` variant above, differing only in how it counts
  processes once the server is past its startup window. So if the main tmux session is ever
  *started* while a second tmux server happens to exist on any socket, that session gets no
  autosave hook for its entire lifetime, silently: no error, no status-line indicator, and
  no retry when the other server later exits. The periodic save simply never happens, and
  the next crash falls back to whatever stale snapshot a previous server wrote. See the
  `status-right` check in the Validation plan below — it is the only cheap way to notice
  this state.
- **The `last`-save symlink is shared across all tmux sockets, with no socket scoping.**
  `tmux-resurrect/scripts/helpers.sh`'s `last_resurrect_file()` is a single
  `$(resurrect_dir)/last` symlink read by `restore.sh` regardless of which socket invokes
  it. A manual rehearsal on an isolated test socket (per the Validation plan below) writes
  to this same shared file — **purge or avoid saving over it during a rehearsal**, since a
  real crash before the next real autosave would otherwise have the real session's restore
  read back the rehearsal's synthetic layout instead of nothing.

  **Know which path that actually is before trying to purge it.** `helpers.sh` resolves
  `resurrect_dir` conditionally: it uses `~/.tmux/resurrect` *only if that directory
  already exists*, and otherwise falls back to
  `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect`. The resurrect README documents
  only the `~/.tmux/resurrect` form, so it is easy to look there, find nothing, and
  conclude no save file exists. On this machine `~/.tmux/resurrect` has never existed and
  `XDG_DATA_HOME` is unset, so the real location is
  **`~/.local/share/tmux/resurrect/last`** — that is the file to inspect or purge. A
  `@resurrect-dir` tmux option overrides the whole rule if the path ever needs pinning.

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
6. Confirm continuum's autosave hook is actually installed *and* able to tick:

   ```bash
   tmux show-options -g status-right     # must contain `continuum_save`
   tmux show-options -g status-interval  # must be non-zero
   ```

   Treat this pair as a permanent acceptance check, not a one-off debugging step. Steps 2–5
   exercise *resurrect*, and they pass just as happily when the thing driving the save is a
   manual `prefix + ctrl-s` — which is exactly what continuum is supposed to make
   unnecessary. Nothing else in this list distinguishes "autosave is running" from the two
   ways it silently isn't: never installed (the multi-server gate, see Known limitations) or
   installed but permanently frozen (`status-interval 0`, see Changes §2). Neither failure
   produces an error, a log line, or a status-line indicator; both are invisible until the
   next crash reveals a stale snapshot. Two read-only lines, zero risk, and together they are
   the only cheap way to tell the three states apart.

**Note on steps 3–5 — they cannot be run literally from inside tmux.** Per the
multi-server bullet in Known limitations, continuum refuses to auto-restore while any other
tmux server is running on any socket, which is always true when the rehearsal is driven
from inside a tmux-hosted session (including a Claude Code CLI session). Don't rediscover
this by waiting on a restore that will never fire: either perform steps 3–5 from a plain
terminal outside tmux, or rehearse on an isolated socket (`tmux -L <name> …`) and invoke
`~/.dotfiles/tmux/plugins/tmux-resurrect/scripts/restore.sh` directly in place of waiting
for continuum's background auto-trigger. If rehearsing, re-read the `last`-symlink bullet
first — the rehearsal writes to the same shared save file the real session restores from.
