# TMUX

## Setup

- Run `~/.dotfiles/bin/setup-terminfo.sh`
- Set iTerm2.app / Terminal.app to use `tmux` as it's terminal type

## Session persistence (resurrect + continuum)

Continuum autosaves every 5 minutes to `~/.local/share/tmux/resurrect/` and restores
automatically the next time a tmux server starts. Design, known limitations, and the
2026-10 outage are in
`docs/superpowers/specs/2026-09-14-tmux-claude-session-persistence-design.md`.

- `make test-tmux-restore` checks the real auto-restore trigger end to end, on an
  isolated socket. Run it after any change to `tmux.conf`, the plugin list, or a plugin
  update.
- Continuum must be the **last** plugin sourced in `tmux.conf`. Otherwise auto-restore
  silently does nothing.
- To start tmux clean once, without a restore, run `touch ~/tmux_no_auto_restore`.
