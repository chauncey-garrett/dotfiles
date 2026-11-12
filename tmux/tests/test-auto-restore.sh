#!/usr/bin/env bash
#
# End-to-end regression test for tmux-continuum's AUTOMATIC restore.
#
# Starts a throwaway tmux server on its own socket using the real dotfiles tmux
# config, and passes only if continuum's auto-restore actually brings back a
# saved session. Running tmux-resurrect's restore.sh by hand does NOT test this.
# The 2026-10 outage was in continuum's trigger: it read resurrect's restore
# path before resurrect had loaded. A direct restore.sh call never reaches that
# code.
#
# Isolation (safe to run from inside your live tmux):
#   - own socket (-L), TMUX unset: never touches the running server
#   - @resurrect-dir -> temp dir holding a synthetic save: the real `last` is
#     never read or written
#   - XDG_CONFIG_HOME -> temp: TPM takes plugin *order* from
#     $XDG_CONFIG_HOME/tmux/tmux.conf, so it sees the probe config, not
#     ~/.tmux.conf
#   - plugins copied to temp with continuum's multi-server gate patched off.
#     That gate skips restore whenever any other tmux server is running, which
#     is always true when you run this from tmux. The patch exists only in the
#     temp copy.
#
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
TIMEOUT="${TIMEOUT:-15}"
work="$(mktemp -d "${TMPDIR:-/tmp}/tmux-restore-test.XXXXXX")"
sock="restore-test-$$"
cleanup() { tmux -L "$sock" kill-server 2>/dev/null || true; rm -rf "$work"; }
trap cleanup EXIT

if [ -e "$HOME/tmux_no_auto_restore" ]; then
  echo "FAIL: ~/tmux_no_auto_restore exists; continuum will never auto-restore" >&2
  exit 1
fi

# 1. Plugin copy with the multi-server gate neutralised.
cp -R "$DOTFILES/tmux/plugins" "$work/plugins"
helpers="$work/plugins/tmux-continuum/scripts/helpers.sh"
perl -0pi -e 's/^another_tmux_server_running_on_startup\(\) \{\n.*?\n\}/another_tmux_server_running_on_startup() { return 1; }/ms' "$helpers"
if ! grep -q '^another_tmux_server_running_on_startup() { return 1; }$' "$helpers"; then
  echo "ERROR: could not patch $helpers; continuum changed shape, update this test" >&2
  exit 2
fi

# 2. A synthetic save that only this test could have written.
mkdir -p "$work/resurrect"
printf 'pane\tsynthetic\t1\t1\t:*\t1\thost\t:%s\t1\tzsh\t:\nwindow\tsynthetic\t1\t:zsh\t1\t:*\tb25d,80x24,0,0,0\t:\nstate\tsynthetic\t\n' \
  "$work" > "$work/resurrect/tmux_resurrect_20000101T000000.txt"
ln -s tmux_resurrect_20000101T000000.txt "$work/resurrect/last"

# 3. Probe config = the real tmux.conf with TPM pointed at the plugin copy.
mkdir -p "$work/xdg/tmux"
{
  sed '/tmux-plugins\/tmux-tpm\.conf/d' "$DOTFILES/tmux/tmux.conf"
  echo "set -g @resurrect-dir '$work/resurrect'"
  echo "set-environment -g TMUX_PLUGIN_MANAGER_PATH '$work/plugins/'"
  echo "set -g @plugin 'tmux-plugins/tpm'"
  echo "run-shell -b '$work/plugins/tpm/tpm'"
} > "$work/xdg/tmux/tmux.conf"

# 4. Start a fresh server (as prezto does at login) and wait for the restore.
env -u TMUX -u TMUX_PANE XDG_CONFIG_HOME="$work/xdg" \
  tmux -L "$sock" -f "$work/xdg/tmux/tmux.conf" new-session -d -s boot
start=$SECONDS
while (( SECONDS - start < TIMEOUT )); do
  if tmux -L "$sock" has-session -t '=synthetic' 2>/dev/null; then
    echo "PASS: continuum auto-restored the saved session after $(( SECONDS - start ))s"
    exit 0
  fi
  sleep 0.2
done

echo "FAIL: no auto-restore within ${TIMEOUT}s" >&2
echo "  sessions: $(tmux -L "$sock" list-sessions -F '#{session_name}' 2>/dev/null | tr '\n' ' ')" >&2
echo "  @resurrect-restore-script-path: '$(tmux -L "$sock" show -gqv @resurrect-restore-script-path)'" >&2
echo "  plugin source order in tmux.conf (continuum must come after resurrect):" >&2
grep -n -E 'tmux-(continuum|resurrect)\.conf' "$DOTFILES/tmux/tmux.conf" | sed 's/^/    /' >&2
exit 1
