#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Running vfox-android-sdk unit tests ==="

# Test 1: Check plugin structure
echo "Test 1: Checking plugin structure..."
for file in metadata.lua hooks/available.lua hooks/pre_install.lua hooks/post_install.lua hooks/env_keys.lua; do
    if [[ ! -f "$PLUGIN_DIR/$file" ]]; then
        echo "FAIL: Missing required file: $file"
        exit 1
    fi
done
echo "PASS: All required plugin files exist"

# Test 2: Validate Lua syntax
echo "Test 2: Validating Lua syntax..."
if command -v luac &>/dev/null; then
    for file in "$PLUGIN_DIR"/*.lua "$PLUGIN_DIR"/hooks/*.lua; do
        if ! luac -p "$file" 2>/dev/null; then
            echo "FAIL: Lua syntax error in $file"
            exit 1
        fi
    done
    echo "PASS: All Lua files have valid syntax"
else
    echo "SKIP: luac not available for syntax checking"
fi

# Test 3: Check metadata.lua contents
echo "Test 3: Checking metadata.lua contents..."
if ! grep -q 'PLUGIN.name = "android-sdk"' "$PLUGIN_DIR/metadata.lua"; then
    echo "FAIL: metadata.lua missing PLUGIN.name"
    exit 1
fi
if ! grep -q 'PLUGIN.version' "$PLUGIN_DIR/metadata.lua"; then
    echo "FAIL: metadata.lua missing PLUGIN.version"
    exit 1
fi
echo "PASS: metadata.lua has required fields"

# Test 4: Check hooks have required functions
echo "Test 4: Checking hook functions..."
if ! grep -q 'function PLUGIN:Available' "$PLUGIN_DIR/hooks/available.lua"; then
    echo "FAIL: available.lua missing PLUGIN:Available function"
    exit 1
fi
if ! grep -q 'function PLUGIN:PreInstall' "$PLUGIN_DIR/hooks/pre_install.lua"; then
    echo "FAIL: pre_install.lua missing PLUGIN:PreInstall function"
    exit 1
fi
if ! grep -q 'function PLUGIN:PostInstall' "$PLUGIN_DIR/hooks/post_install.lua"; then
    echo "FAIL: post_install.lua missing PLUGIN:PostInstall function"
    exit 1
fi
if ! grep -q 'function PLUGIN:EnvKeys' "$PLUGIN_DIR/hooks/env_keys.lua"; then
    echo "FAIL: env_keys.lua missing PLUGIN:EnvKeys function"
    exit 1
fi
echo "PASS: All hooks have required functions"

# Test 5: Verify test resources exist
echo "Test 5: Checking test resources..."
if [[ ! -f "$SCRIPT_DIR/resources/repository2-3.xml" ]]; then
    echo "FAIL: Missing test resource: repository2-3.xml"
    exit 1
fi
echo "PASS: Test resources exist"

echo ""
echo "=== All tests passed ==="
