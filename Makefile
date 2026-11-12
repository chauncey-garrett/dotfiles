.DEFAULT_GOAL := help
.PHONY: help test test-tmux-restore

help: ## List available targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

test: test-tmux-restore ## Run all checks

test-tmux-restore: ## E2E: continuum auto-restores a saved session on a fresh tmux server (isolated socket; safe from inside tmux)
	@tmux/tests/test-auto-restore.sh
