# Development Environment Management
# Usage: make help

.PHONY: setup setup-dry-run status doctor backup wp-up wp-down wp-stop wp-status help

.DEFAULT_GOAL := help

# Setup targets
setup:
	@bash scripts/setup.sh

setup-dry-run:
	@bash scripts/setup.sh --dry-run

setup-minimal:
	@bash scripts/setup.sh --config minimal

setup-phase:
	@if [ -z "$(PHASE)" ]; then \
		echo "Usage: make setup-phase PHASE=1"; \
		exit 1; \
	fi
	@bash scripts/setup.sh --phase $(PHASE)

# Status & diagnostics
status:
	@echo "=== Tool Status ==="
	@for cmd in fd rg bat eza delta lazygit nvim tmux node docker gh fzf zoxide starship direnv jq yq atuin; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			printf "  %-12s ✅  %s\n" "$$cmd" "$$(command -v $$cmd)"; \
		else \
			printf "  %-12s ❌  not found\n" "$$cmd"; \
		fi; \
	done
	@echo ""
	@echo "=== System ==="
	@printf "  %-12s %s\n" "Memory" "$$(free -h | awk '/^Mem:/ {print $$3 "/" $$2}')"
	@printf "  %-12s %s\n" "Disk" "$$(df -h $$HOME | awk 'NR==2 {print $$3 "/" $$2 " (" $$5 ")"}')"
	@printf "  %-12s %s\n" "Swappiness" "$$(cat /proc/sys/vm/swappiness)"

doctor:
	@echo "=== Environment Doctor ==="
	@echo "Checking shell config..."
	@bash -n ~/.bashrc 2>&1 && echo "  .bashrc syntax: OK" || echo "  .bashrc syntax: ERROR"
	@echo "Checking scripts..."
	@for f in scripts/setup.sh scripts/lib/*.sh; do \
		bash -n "$$f" 2>&1 && printf "  %-35s OK\n" "$$f" || printf "  %-35s ERROR\n" "$$f"; \
	done

# Backup
backup:
	@BACKUP_DIR="$$HOME/.config-backup/$$(date +%Y%m%d-%H%M%S)"; \
	mkdir -p "$$BACKUP_DIR"; \
	for f in ~/.bashrc ~/.gitconfig ~/.tmux.conf ~/.config/starship.toml ~/.config/nvim/init.lua; do \
		[ -f "$$f" ] && cp "$$f" "$$BACKUP_DIR/" && echo "Backed up: $$f"; \
	done; \
	echo "Backup saved to: $$BACKUP_DIR"

# WordPress Docker helpers
wp-up:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Usage: make wp-up PROJECT=aimy"; \
		echo "Available: aimy, tkc"; \
		exit 1; \
	fi
	@bash -ic 'wp-up $(PROJECT)'

wp-down:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Usage: make wp-down PROJECT=aimy"; \
		exit 1; \
	fi
	@bash -ic 'wp-down $(PROJECT)'

wp-stop:
	@bash -ic 'wp-stop-all'

wp-status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -20 || echo "Docker not running"

# Test
test:
	@bash scripts/tests/test-dry-run.sh

# Help
help:
	@echo "Development Environment Management"
	@echo ""
	@echo "Setup:"
	@echo "  make setup            Full environment setup"
	@echo "  make setup-dry-run    Preview without changes"
	@echo "  make setup-minimal    Minimal install"
	@echo "  make setup-phase PHASE=N  Run specific phase (1-6)"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make status           Show tool installation status"
	@echo "  make doctor           Check config syntax"
	@echo "  make backup           Backup config files"
	@echo ""
	@echo "WordPress:"
	@echo "  make wp-up PROJECT=aimy    Start project"
	@echo "  make wp-down PROJECT=aimy  Stop project"
	@echo "  make wp-stop               Stop all projects"
	@echo "  make wp-status             Show container status"
	@echo ""
	@echo "Test:"
	@echo "  make test             Run dry-run test"
