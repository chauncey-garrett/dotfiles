#!/usr/bin/env bash
#
# Tests for the two halves of live Claude session tracking:
#   tmux/bin/claude-session-to-tmux    Claude Code SessionStart hook: records the
#                                      pane's session id as pane option @claude-session-id
#   tmux/bin/resurrect-save-claude-ids resurrect post-save-layout hook: writes those
#                                      ids into each save as claude_session lines
#
# Runs on an isolated tmux server (-L, -f /dev/null). A fake `claude` script
# stands in for Claude Code and runs the hook the way Claude does (via a shell,
# with the hook JSON on stdin), so the process-ancestry rule is exercised for real.
#
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
HOOK="$DOTFILES/tmux/bin/claude-session-to-tmux"
SAVEHOOK="$DOTFILES/tmux/bin/resurrect-save-claude-ids"
work="$(mktemp -d "${TMPDIR:-/tmp}/claude-tracking-test.XXXXXX")"
sock="tracking-test-$$"
t() { tmux -L "$sock" "$@"; }
cleanup() { t kill-server 2>/dev/null || true; rm -rf "$work"; }
trap cleanup EXIT
fails=0
ok()   { echo "ok   $1"; }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

# Fake claude. Mode "run": fire the SessionStart hook for id $2 through a shell,
# as Claude Code does. Mode "nest": launch another claude (like a hook running
# `claude -p`), which then fires the hook itself.
mkdir -p "$work/bin"
cat > "$work/bin/claude" <<EOF
#!/bin/bash
case "\$1" in
  run)  printf '{"session_id":"%s","source":"startup"}' "\$2" | /bin/sh -c '"$HOOK"' > "$work/out.\$2" ;;
  nest) /bin/sh -c '"$work/bin/claude" run '"\$2" ;;
esac
touch "$work/done.\$2"
sleep 300
EOF
chmod +x "$work/bin/claude"

ID1=11111111-aaaa-bbbb-cccc-000000000001   # claude as a child of the pane's shell
ID2=11111111-aaaa-bbbb-cccc-000000000002   # claude as the pane's own process
ID3=11111111-aaaa-bbbb-cccc-000000000003   # nested claude: must NOT be recorded
t -f /dev/null new-session -d -s T -n child "bash -c '\"$work/bin/claude\" run $ID1; sleep 300'"
t new-window -t T: -n direct "$work/bin/claude run $ID2"
t new-window -t T: -n nested "bash -c '\"$work/bin/claude\" nest $ID3; sleep 300'"
t new-window -t T: -n plain  "sleep 300"

for id in $ID1 $ID2 $ID3; do
  for _ in $(seq 1 50); do [ -e "$work/done.$id" ] && break; sleep 0.1; done
  [ -e "$work/done.$id" ] || fail "fake claude $id never ran"
done
opt() { t show-options -p -t "T:$1" -qv @claude-session-id; }

[ "$(opt child)"  = "$ID1" ] && ok "records claude started from the pane's shell" || fail "child pane: got '$(opt child)'"
[ "$(opt direct)" = "$ID2" ] && ok "records claude that is the pane process"      || fail "direct pane: got '$(opt direct)'"
[ -z "$(opt nested)" ]       && ok "ignores nested claude (e.g. a hook's claude -p)" || fail "nested pane: got '$(opt nested)'"
noisy=""
for id in $ID1 $ID2 $ID3; do [ ! -s "$work/out.$id" ] || noisy="$noisy $id"; done
[ -z "$noisy" ] && ok "hook prints nothing" || fail "hook printed to stdout for:$noisy (would be injected into Claude's context)"

# Outside tmux, or with junk input: exit 0, no output, no error.
rc=0; out="$(env -u TMUX -u TMUX_PANE "$HOOK" <<<'{"session_id":"'"$ID1"'"}' 2>&1)" || rc=$?
[ $rc -eq 0 ] && [ -z "$out" ] && ok "outside tmux: silent no-op" || fail "outside tmux: rc=$rc out='$out'"
rc=0; out="$("$HOOK" <<<'not json' 2>&1)" || rc=$?
[ $rc -eq 0 ] && [ -z "$out" ] && ok "bad input: silent no-op" || fail "bad input: rc=$rc out='$out'"

# Save hook: one claude_session line per pane that has an id, appended to the save.
printf 'pane\tT\t1\t1\t:*\t0\tt\t:/x\t1\tbash\t:x\n' > "$work/save.txt"
TMUX="$(t display -p '#{socket_path}'),0,0" "$SAVEHOOK" "$work/save.txt"
got="$(grep '^claude_session' "$work/save.txt" | sort)"
want="$(printf 'claude_session\tT\t%s\t0\t%s\n' "$(t display -p -t T:child '#{window_index}')" "$ID1" \
                                                "$(t display -p -t T:direct '#{window_index}')" "$ID2" | sort)"
[ "$got" = "$want" ] && ok "save hook writes one line per tracked pane" || { fail "save hook"; echo "     want: $want"; echo "     got:  $got"; }
[ "$(head -1 "$work/save.txt" | cut -f1)" = pane ] && ok "save hook appends, keeps resurrect's lines" || fail "save hook clobbered the save"

if [ "$fails" -eq 0 ]; then echo "PASS: claude session tracking"; else echo "FAIL: $fails case(s)" >&2; exit 1; fi
