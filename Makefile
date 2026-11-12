.DEFAULT_GOAL := help
.PHONY: help test test-claude-restore test-claude-session-tracking test-tmux-restore

help: ## List available targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: test-claude-restore test-claude-session-tracking test-tmux-restore ## Run all checks

test-claude-restore: ## Unit: claude-restore relaunches each saved Claude pane with its own session id
	@tmux/tests/test-claude-restore.sh

test-claude-session-tracking: ## SessionStart hook records each pane's live session id; resurrect saves it (isolated socket)
	@tmux/tests/test-claude-session-tracking.sh

test-tmux-restore: ## E2E: a fresh tmux server auto-restores a saved session, and its Claude pane resumes its own id (isolated socket; safe from inside tmux)
	@tmux/tests/test-auto-restore.sh
