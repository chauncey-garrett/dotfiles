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
# Window 2 holds a saved Claude pane, so the restore also exercises resurrect's
# `->… *` argument hand-off to claude-restore.
# Window 3 is a pane started as plain `claude`: its id exists only as a
# claude_session line, the way resurrect-save-claude-ids records it.
SID=11111111-2222-3333-4444-555555555555
SID3=33333333-2222-3333-4444-555555555555
printf 'pane\tsynthetic\t1\t1\t:*\t1\thost\t:%s\t1\tzsh\t:\npane\tsynthetic\t2\t0\t:\t1\tclaude\t:%s\t1\tclaude\t:claude -r %s\npane\tsynthetic\t3\t0\t:\t1\tclaude\t:%s\t1\tclaude\t:claude\nwindow\tsynthetic\t1\t:zsh\t1\t:*\tb25d,80x24,0,0,0\t:\nwindow\tsynthetic\t2\t:claude\t0\t:\tb25d,80x24,0,0,1\toff\nwindow\tsynthetic\t3\t:plain\t0\t:\tb25d,80x24,0,0,2\toff\nstate\tsynthetic\t\nclaude_session\tsynthetic\t3\t1\t%s\n' \
  "$work" "$work" "$SID" "$work" "$SID3" > "$work/resurrect/tmux_resurrect_20000101T000000.txt"
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
#    CLAUDE_RESTORE_DRY_RUN makes claude-restore print its command instead of
#    launching Claude, so no real session starts.
env -u TMUX -u TMUX_PANE XDG_CONFIG_HOME="$work/xdg" CLAUDE_RESTORE_DRY_RUN=1 \
  tmux -L "$sock" -f "$work/xdg/tmux/tmux.conf" new-session -d -s boot
start=$SECONDS
while (( SECONDS - start < TIMEOUT )); do
  if tmux -L "$sock" has-session -t '=synthetic' 2>/dev/null; then
    echo "PASS: continuum auto-restored the saved session after $(( SECONDS - start ))s"
    # 5. The Claude pane must come back resuming its own saved id. This takes
    #    about 10s while the login shell initialises.
    for case in "2|$SID|saved as claude -r <id>" "3|$SID3|plain claude, id from claude_session line"; do
      IFS='|' read -r win id label <<<"$case"
      want="claude --resume $id"
      until tmux -L "$sock" capture-pane -p -t "=synthetic:$win" 2>/dev/null | grep -qF -- "$want"; do
        if (( SECONDS - start >= TIMEOUT + 45 )); then
          echo "FAIL: restored pane $win ($label) never ran '$want'. Pane shows:" >&2
          tmux -L "$sock" capture-pane -p -t "=synthetic:$win" 2>/dev/null | grep -v '^\s*$' | tail -5 | sed 's/^/    /' >&2
          echo "  @resurrect-processes: $(tmux -L "$sock" show -gqv @resurrect-processes)" >&2
          exit 1
        fi
        sleep 0.5
      done
      echo "PASS: restored pane $win ($label) ran '$want' after $(( SECONDS - start ))s"
    done

    # 6. Save side: a real resurrect save must record a pane's live id.
    SAVED=44444444-2222-3333-4444-555555555555
    tmux -L "$sock" set-option -p -t '=synthetic:3' @claude-session-id "$SAVED"
    tmux -L "$sock" run-shell "$work/plugins/tmux-resurrect/scripts/save.sh quiet"
    newest="$work/resurrect/$(readlink "$work/resurrect/last")"
    if grep -qxF "$(printf 'claude_session\tsynthetic\t3\t1\t%s' "$SAVED")" "$newest"; then
      echo "PASS: resurrect save recorded the pane's live session id"
      exit 0
    fi
    echo "FAIL: resurrect save has no claude_session line for synthetic:3. Lines:" >&2
    grep '^claude_session' "$newest" | sed 's/^/    /' >&2 || echo "    (none)" >&2
    echo "  @resurrect-hook-post-save-layout: '$(tmux -L "$sock" show -gqv @resurrect-hook-post-save-layout)'" >&2
    exit 1
  fi
  sleep 0.2
done

echo "FAIL: no auto-restore within ${TIMEOUT}s" >&2
echo "  sessions: $(tmux -L "$sock" list-sessions -F '#{session_name}' 2>/dev/null | tr '\n' ' ')" >&2
echo "  @resurrect-restore-script-path: '$(tmux -L "$sock" show -gqv @resurrect-restore-script-path)'" >&2
echo "  plugin source order in tmux.conf (continuum must come after resurrect):" >&2
grep -n -E 'tmux-(continuum|resurrect)\.conf' "$DOTFILES/tmux/tmux.conf" | sed 's/^/    /' >&2
exit 1
