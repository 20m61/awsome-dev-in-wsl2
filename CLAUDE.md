# Claude Code Instructions

## Project

WSL2 development environment automation scripts (bash).

## Preferences

- Language: 日本語でコミュニケーション
- Code/Commits: English

## Coding Style (Bash)

- `set -euo pipefail` in all scripts
- `[[ ]]` over `[ ]`
- Quote all variables: `"$var"` not `$var`
- `local` for function-scoped variables
- Functions: `snake_case()`
- Constants: `UPPER_SNAKE_CASE` with `readonly`
- Support `DRY_RUN` mode in all install functions
- Idempotent: check before install

## Git

```
feat: fix: docs: refactor: test: chore:
```

### Branch Strategy

- **NEVER commit/push directly to `main`**
- All development on `develop` or topic branches
- Releases via PR: `develop` -> `main`

## Testing

```bash
make test       # Run dry-run tests
make doctor     # Syntax check
```

## Security

**DO NOT modify:** `.env*`, `credentials.json`, `secrets.json`, `*.pem`, `*.key`
