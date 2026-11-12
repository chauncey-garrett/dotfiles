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

### 5. Plugin load order and restore window (added 2026-11-12, after an outage)

**What happened.** Auto-restore never fired from 2026-10-08 to 2026-11-12. When tmux
started on 2026-11-11, you got one bare session. Resurrect's 30-day backup pruning then
deleted the last real snapshot, which covered six windows from 2026-10-08. The sessions had
to be rebuilt by hand from the Claude transcripts.

**Root cause.** `continuum_restore.sh` sleeps 1s and then reads
`@resurrect-restore-script-path`. Resurrect's own `resurrect.tmux` sets that option. TPM
loads plugins in the order their `source` lines appear in `tmux.conf`, and continuum was
sourced *before* resurrect, with four plugins in between. The read therefore came back
empty, and `[ -n "$path" ]` skipped the restore with no error. Measured warm: the path
appeared 0.25–0.53s too late on 3 of 3 runs. In an A/B test on isolated servers, the old
order restored 0 of 3 times and continuum-last restored 3 of 3. The original rehearsal
passed because it called `restore.sh` directly, which skips this trigger path entirely (see
the Validation plan).

**Changes.**
- `tmux.conf` now sources `tmux-continuum.conf` **last** among the plugins. A comment there
  explains why. Continuum's README already asks for this, for its `status-right` hook.
- `@continuum-restore-max-delay '30'` (default 10). Continuum's restore fires only if
  `continuum.tmux` runs within that many seconds of server start. Loading last moves it to
  about 3s warm, and a cold boot under endpoint security can be several times slower.
  Resurrect skips panes that already exist, so a wider window cannot duplicate windows.
- `make test-tmux-restore` (`tmux/tests/test-auto-restore.sh`) is the regression test. It
  exercises the real trigger (see the Validation plan).

### 6. Restore each Claude pane by its saved session id (added 2026-11-12)

The original `"~claude->claude --continue"` setting dropped the session id that resurrect
had already saved. With the six windows open on 2026-11-12, it would have restored 2 of
them wrong:
- Two panes in `~/dev` would both resume the newest `~/dev` conversation.
- The nri-bundle worktree pane would not find its session at all. `--continue` from the
  worktree directory looks under the worktree's project slug, but a session started with
  `claude --worktree <name>` is stored under the *main* checkout's slug.

Resurrect's inline strategy replaces a ` *` in the replacement with the saved command's
arguments (`_get_command_arguments` in `process_restore_helpers.sh`). So the setting is now
`"~claude->~/.dotfiles/tmux/bin/claude-restore *"`, and the resolver decides:

| Saved command | Relaunched as |
|---|---|
| `claude -r <id>`, `--resume <id>`, `--resume=<id>` | `claude --resume <id>` |
| `claude --worktree <name> --resume <id>` | the same command, run from the main checkout (found with `git rev-parse --git-common-dir`) |
| anything else (bare, a positional prompt, `-p`, `--resume` with no id) | `fallback_args` |

Every other argument is dropped. In particular a positional prompt is never replayed,
because replaying it would submit the prompt again to an auto-mode session. The resolver
exports `SHELL=/bin/bash` to match the zshrc `claude` alias (`e56a3f7`), since scripts
don't inherit aliases. `make test-claude-restore` covers the decision table.
`make test-tmux-restore` restores a saved `claude -r <id>` pane through the real
resurrect path, with `CLAUDE_RESTORE_DRY_RUN=1`, and checks that it ran
`claude --resume <id>`.

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
- **Panes started as plain `claude` have no session id in the save.** Resurrect records
  only the process's command line, and a pane started as bare `claude` has nothing to
  resume by. `claude-restore` gives those panes its `fallback_args`. Panes saved with
  `-r <id>` or `--resume <id>` resume exactly that conversation (Changes §6). Two
  bare-`claude` panes in one directory can still both get the newest conversation under a
  `--continue` fallback.
- **Claude Code prunes idle transcripts (`cleanupPeriodDays`, default 30).** A session
  that stays open but idle for more than 30 days loses its transcript to the next
  `claude` launch, so no restore can resume it. Observed 2026-11-12: `7b8ac24c`
  (dotfiles, idle since 2026-09-03) existed only in the episodic-memory archive.
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
  At a real boot this gate passes: with one terminal window, the only other `tmux`
  process is prezto's `tmux attach-session` client. On 2026-11-12, across 12 checks,
  TPM's and continuum's own `tmux` calls never overlapped the count. It *does* trip
  if several terminal windows or tabs attach at login at the same moment. A rehearsal
  from inside a running tmux always trips it, which is why `make test-tmux-restore`
  patches this gate out in a temporary copy of the plugins. Do **not** rehearse by calling
  `restore.sh` directly: that skips continuum's trigger, and the trigger is where the
  2026-10 outage was (Changes §5).

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

**Steps 3–5 cannot be run literally from inside tmux: run `make test-tmux-restore`
instead.** Continuum refuses to auto-restore while any other tmux server is running (see
Known limitations), and a rehearsal driven from a tmux-hosted session always has one. The
old workaround was to call `restore.sh` directly on an isolated socket. **That is the
reason the 2026-10 outage shipped**: it tests resurrect and skips continuum's trigger,
which is where the bug was (Changes §5). The make target runs a fresh server on its own
socket with the real `tmux.conf`, a synthetic save in a temporary `@resurrect-dir`
(so it cannot touch the real `last`), and `XDG_CONFIG_HOME` pointed at the probe config
so TPM uses its plugin order. It passes only if continuum's automatic restore brings the
saved session back. Run it after any change to `tmux.conf`, the plugin list, or a plugin
update.
