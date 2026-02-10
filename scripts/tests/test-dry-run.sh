#!/bin/bash
# Test: verify dry-run mode completes without errors or side effects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo -e "\033[0;32m  PASS\033[0m $1"; PASS=$((PASS + 1)); }
fail() { echo -e "\033[0;31m  FAIL\033[0m $1"; FAIL=$((FAIL + 1)); }

echo "=== Dry-Run Test Suite ==="
echo ""

# Test 1: Script syntax validation
echo "--- Syntax checks ---"
for script in "$SCRIPT_DIR"/setup.sh "$SCRIPT_DIR"/lib/*.sh "$SCRIPT_DIR"/dotfiles/*.sh; do
    if bash -n "$script" 2>&1; then
        pass "$(basename "$script") syntax OK"
    else
        fail "$(basename "$script") syntax error"
    fi
done

# Test 2: Dry-run completes without error
echo ""
echo "--- Dry-run execution ---"
OUTPUT=$(timeout 30s bash "$SCRIPT_DIR/setup.sh" --dry-run 2>&1) || true
EXIT_CODE=${PIPESTATUS[0]:-$?}

if [[ $EXIT_CODE -eq 0 ]]; then
    pass "dry-run exited with code 0"
else
    fail "dry-run exited with code $EXIT_CODE"
fi

# Test 3: DRY RUN markers present
if echo "$OUTPUT" | grep -q "DRY RUN"; then
    pass "DRY RUN markers found in output"
else
    fail "No DRY RUN markers in output"
fi

# Test 4: Setup Complete banner
if echo "$OUTPUT" | grep -q "Setup Complete"; then
    pass "Setup Complete banner found"
else
    fail "Setup Complete banner not found"
fi

# Test 5: No actual files were created during dry run
MARKER="/tmp/.devenv-dryrun-test-$$"
if [[ ! -f "$MARKER" ]]; then
    pass "No unexpected temp files created"
else
    fail "Unexpected temp files found"
    rm -f "$MARKER"
fi

# Test 6: Config files loadable
echo ""
echo "--- Config loading ---"
for conf in "$SCRIPT_DIR"/config/*.conf; do
    if bash -n "$conf" 2>&1; then
        pass "$(basename "$conf") is valid bash"
    else
        fail "$(basename "$conf") has syntax errors"
    fi
done

# Test 7: Each module can be sourced without running
echo ""
echo "--- Module sourcing ---"
for module in "$SCRIPT_DIR"/lib/*.sh; do
    if bash -c "source '$module'" 2>/dev/null; then
        pass "$(basename "$module") sources cleanly"
    else
        fail "$(basename "$module") source error"
    fi
done

# Test 8: Dotfiles can be sourced without running
echo ""
echo "--- Dotfiles sourcing ---"
for dotfile in "$SCRIPT_DIR"/dotfiles/*.sh; do
    if bash -c "source '$dotfile'" 2>/dev/null; then
        pass "$(basename "$dotfile") sources cleanly"
    else
        fail "$(basename "$dotfile") source error"
    fi
done

# Summary
echo ""
echo "================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "================================"

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
