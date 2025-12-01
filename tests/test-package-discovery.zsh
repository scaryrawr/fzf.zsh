#!/usr/bin/env zsh
# Test script for package widget discovery functions
# Usage: zsh test-package-discovery.zsh <npm|pnpm|cargo>

SCRIPT_DIR="${0:A:h}"
WIDGET_DIR="$SCRIPT_DIR/../widgets"

# Source the widget
source "$WIDGET_DIR/fzf-package-widget.zsh"

test_type="$1"
cache_file="/tmp/test-packages-$$.json"

# Initialize empty cache
echo '[]' > "$cache_file"

cleanup() {
    rm -f "$cache_file" "${cache_file}.tmp"
}
trap cleanup EXIT

passed=0
failed=0

assert_contains() {
    local name="$1"
    local cache="$2"
    if jq -e ".[] | select(.name == \"$name\")" "$cache" > /dev/null 2>&1; then
        echo "✓ Found package: $name"
        passed=$((passed + 1))
    else
        echo "✗ Missing package: $name"
        failed=$((failed + 1))
    fi
}

assert_path_valid() {
    local name="$1"
    local cache="$2"
    local path=$(jq -r ".[] | select(.name == \"$name\") | .path" "$cache" | head -1)
    # Handle both absolute and relative paths
    if [[ -f "$path" ]] || [[ -f "./$path" ]]; then
        echo "✓ Valid path for $name: $path"
        passed=$((passed + 1))
    else
        echo "✗ Invalid path for $name: $path (file not found)"
        failed=$((failed + 1))
    fi
}

case "$test_type" in
    npm)
        echo "=== Testing npm workspace discovery ==="
        fzf_package_widget_handle_npm_workspaces "$cache_file"
        
        echo ""
        echo "Cache contents:"
        jq '.' "$cache_file"
        echo ""
        
        # Expected packages from fixture
        assert_contains "pkg-a" "$cache_file"
        assert_contains "pkg-b" "$cache_file"
        assert_path_valid "pkg-a" "$cache_file"
        assert_path_valid "pkg-b" "$cache_file"
        ;;
    
    pnpm)
        echo "=== Testing pnpm workspace discovery ==="
        fzf_package_widget_handle_pnpm "$cache_file"
        
        echo ""
        echo "Cache contents:"
        jq '.' "$cache_file"
        echo ""
        
        # Expected packages from fixture
        assert_contains "pkg-a" "$cache_file"
        assert_contains "pkg-b" "$cache_file"
        assert_contains "shared-utils" "$cache_file"
        assert_path_valid "pkg-a" "$cache_file"
        assert_path_valid "pkg-b" "$cache_file"
        assert_path_valid "shared-utils" "$cache_file"
        ;;
    
    cargo)
        echo "=== Testing cargo workspace discovery ==="
        fzf_package_widget_handle_cargo "$cache_file"
        
        echo ""
        echo "Cache contents:"
        jq '.' "$cache_file"
        echo ""
        
        # Expected packages from fixture
        assert_contains "crate-a" "$cache_file"
        assert_contains "crate-b" "$cache_file"
        assert_path_valid "crate-a" "$cache_file"
        assert_path_valid "crate-b" "$cache_file"
        ;;
    
    *)
        echo "Usage: $0 <npm|pnpm|cargo>"
        exit 1
        ;;
esac

echo ""
echo "=== Results ==="
echo "Passed: $passed"
echo "Failed: $failed"

if [[ $failed -gt 0 ]]; then
    exit 1
fi
