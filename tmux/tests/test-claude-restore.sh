#!/usr/bin/env bash
#
# Unit tests for tmux/bin/claude-restore: the command tmux-resurrect runs in a
# restored pane that had been running Claude Code. Runs it in dry-run mode
# (CLAUDE_RESTORE_DRY_RUN=1 prints "cd <dir>" and "claude <args>" instead of
# exec'ing claude), so no session is started.
#
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CR="$DOTFILES/tmux/bin/claude-restore"
work="$(mktemp -d "${TMPDIR:-/tmp}/claude-restore-test.XXXXXX")"
work="$(cd "$work" && pwd -P)" # resolve /var -> /private/var so paths compare equal
trap 'rm -rf "$work"' EXIT
fails=0

# Isolation: claude-restore looks up this pane's live session id in the resurrect
# save. Point it at an empty save and a pane that doesn't exist, so these tests
# never read the real ~/.local/share/tmux/resurrect/last, even when run inside tmux.
: > "$work/empty-save.txt"
export CLAUDE_RESTORE_SAVE_FILE="$work/empty-save.txt"
export CLAUDE_RESTORE_PANE=$'none\t0\t0'

run() { (cd "$1" && shift && CLAUDE_RESTORE_DRY_RUN=1 "$CR" "$@"); }

expect() { # name dir expected-output args...
  local name=$1 dir=$2 want=$3; shift 3
  local got; got="$(run "$dir" "$@" 2>&1)" || got="EXIT $?: $got"
  if [ "$got" == "$want" ]; then echo "ok   $name"
  else echo "FAIL $name"; echo "     want: $(echo "$want" | tr '\n' '|')"; echo "     got:  $(echo "$got" | tr '\n' '|')"; fails=$((fails + 1)); fi
}

plain="$work/plain"; mkdir -p "$plain"
ID=5b04030d-c9c9-4ad9-8af6-6afd093e8000

# A saved session id always wins, however it was spelled.
expect "short -r"         "$plain" $'cd '"$plain"$'\nclaude --resume '"$ID"  -r "$ID"
expect "long --resume"    "$plain" $'cd '"$plain"$'\nclaude --resume '"$ID"  --resume "$ID"
expect "--resume=ID"      "$plain" $'cd '"$plain"$'\nclaude --resume '"$ID"  "--resume=$ID"
expect "other flags drop" "$plain" $'cd '"$plain"$'\nclaude --resume '"$ID"  --model opus -r "$ID" --permission-mode auto

# Worktree sessions: their transcript lives under the MAIN checkout's project
# dir, so relaunch from there with --worktree, the command that resumes them.
main="$work/repo"
git init -q "$main"
git -C "$main" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
git -C "$main" worktree add -q "$main/.claude/worktrees/wt" -b wt
wt="$main/.claude/worktrees/wt"
expect "worktree -> main checkout" "$wt" $'cd '"$main"$'\nclaude --worktree wt --resume '"$ID"  --worktree wt --resume "$ID"
expect "worktree outside git drops --worktree" "$plain" $'cd '"$plain"$'\nclaude --resume '"$ID"  --worktree wt --resume "$ID"

# No session id saved: every such shape must take the SAME fallback (whatever
# fallback_args decides), and must never replay a prompt or a one-shot flag.
fallback="$(run "$plain")"
expect "bare claude"            "$plain" "$fallback"
expect "positional prompt"      "$plain" "$fallback"  "fix the failing test"
expect "print mode"             "$plain" "$fallback"  -p "summarize the repo"
expect "--resume with no id"    "$plain" "$fallback"  --resume
expect "--resume then a flag"   "$plain" "$fallback"  --resume --model opus
case "$fallback" in
  *"fix the"*|*" -p"*|*summarize*) echo "FAIL fallback leaks a prompt: $fallback"; fails=$((fails + 1)) ;;
  "cd $plain"$'\n'"claude"*) echo "ok   fallback shape ($(echo "$fallback" | tail -1))" ;;
  *) echo "FAIL fallback is not 'cd <dir>' + 'claude …': $fallback"; fails=$((fails + 1)) ;;
esac

# Live session ids recorded in the save (claude_session lines, written by
# resurrect-save-claude-ids from the SessionStart hook's pane option). This is
# what makes panes started as plain `claude` restore exactly.
LIVE=aaaaaaaa-1111-2222-3333-444444444444
CMD=cccccccc-1111-2222-3333-444444444444
printf 'pane\tS\t3\t1\t:*\t1\tt\t:/x\t1\tclaude\t:claude\nclaude_session\tS\t3\t1\t%s\nclaude_session\tS\t4\t1\tdddddddd-1111-2222-3333-444444444444\nclaude_session\tS\t6\t1\tnot-a-uuid\n' \
  "$LIVE" > "$work/save.txt"
export CLAUDE_RESTORE_SAVE_FILE="$work/save.txt"

export CLAUDE_RESTORE_PANE=$'S\t3\t1'
expect "saved id, plain claude"          "$plain" $'cd '"$plain"$'\nclaude --resume '"$LIVE"
expect "saved id beats command-line id"  "$plain" $'cd '"$plain"$'\nclaude --resume '"$LIVE"  -r "$CMD"
expect "saved id + worktree"             "$wt"    $'cd '"$main"$'\nclaude --worktree wt --resume '"$LIVE"  --worktree wt

export CLAUDE_RESTORE_PANE=$'S\t5\t1'
expect "another pane's id is not used"   "$plain" $'cd '"$plain"$'\nclaude --resume '"$CMD"  -r "$CMD"
expect "no saved id -> fallback"         "$plain" "$fallback"

export CLAUDE_RESTORE_PANE=$'S\t6\t1'
expect "malformed saved id is ignored"   "$plain" "$fallback"

if [ "$fails" -eq 0 ]; then echo "PASS: claude-restore"; else echo "FAIL: $fails case(s)" >&2; exit 1; fi
