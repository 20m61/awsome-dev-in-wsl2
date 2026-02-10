# Contributing

## Branch Strategy

- **Never** commit/push directly to `main` - releases only via PR from `develop`
- All development on `develop` or topic branches

### Branch Naming

```
feature/<description>   # New features
fix/<description>        # Bug fixes
refactor/<description>   # Code refactoring
docs/<description>       # Documentation
```

## Development

### Prerequisites

```bash
# Clone
ghq get 20m61/awsome-dev-in-wsl2
cd ~/repos/github.com/20m61/awsome-dev-in-wsl2

# Switch to develop branch
git checkout develop
```

### Adding a New Tool

1. Determine which phase/module it belongs to
2. Add install function to the appropriate `scripts/lib/*.sh`
3. Follow the existing pattern:

```bash
install_newtool() {
    if command_exists newtool; then
        log_info "newtool is already installed"
        return 0
    fi

    log_info "Installing newtool..."
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        echo -e "  ${YELLOW}[DRY RUN]${NC} install newtool"
        return 0
    fi

    # Install logic here
    log_info "newtool installed"
}
```

4. Call the function from the module's `setup_*()` function
5. Add to config files if it should be toggleable
6. Update documentation

### Testing

```bash
# Syntax check all scripts
make doctor

# Run dry-run test
make test

# Manual dry-run
./scripts/setup.sh --dry-run
```

## Commit Messages

```
feat: add new tool installation
fix: correct download URL for sd
docs: update cheatsheet with new aliases
refactor: extract common download logic
test: add integration test for phase 2
chore: update tool versions
```

## Code Style

- `set -euo pipefail` in all scripts (except sourced dotfiles — add a comment explaining why)
- Use `[[ ]]` over `[ ]`
- Quote all variables
- Use `local` for function-scoped variables
- Check `command_exists` before assuming tools are available
- Support `DRY_RUN` mode in all install functions

## Error Handling

- All `curl` downloads must use `-f` (--fail) to detect HTTP errors
- Never pipe `curl` directly to `sh` — download to temp file first
- Orchestrator functions (`setup_*`) must propagate child failures with `|| return 1`
- Validate user inputs: branch names (`git check-ref-format`), repo format (regex)
- Avoid `grep -oP` — use bash parameter expansion or `sed` for POSIX compatibility

See [docs/architecture.md](docs/architecture.md) for detailed patterns and examples.
