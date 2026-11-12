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

if [ "$fails" -eq 0 ]; then echo "PASS: claude-restore"; else echo "FAIL: $fails case(s)" >&2; exit 1; fi
