#!/usr/bin/env bash
set -euo pipefail

# Test script for android-backup.sh subcommand refactoring

SCRIPT="./android-backup.sh"

echo "Running tests for android-backup.sh subcommands..."

# 1. Test help output
echo "Test 1: Help output"
if grep -q "Commands:" < <("$SCRIPT" --help); then
    echo "  - SUCCESS: Help contains 'Commands:'"
else
    echo "  - FAILURE: Help does not contain 'Commands:'"
    exit 1
fi

# 2. Test devices subcommand
echo "Test 2: 'devices' subcommand"
output=$("$SCRIPT" devices 2>&1 || true)
if [[ "$output" == *"No devices connected"* ]] || [[ "$output" == *"Connected devices:"* ]] || [[ "$output" == *"adb is not installed"* ]] || [[ "$output" == *"Failed to connect to ADB server"* ]]; then
    echo "  - SUCCESS: 'devices' subcommand recognized"
else
    echo "  - FAILURE: 'devices' subcommand not recognized (Result: $output)"
    exit 1
fi

# 3. Test backup subcommand (should fail if params are missing)
echo "Test 3: 'backup' subcommand validation"
# We expect this to fail with either a device error OR a validation error
# But we specifically want to see if the command 'backup' is recognized
output=$("$SCRIPT" backup --help 2>&1 || true)
if [[ "$output" == *"Usage: "* ]]; then
    echo "  - SUCCESS: 'backup' subcommand recognized help"
else
    echo "  - FAILURE: 'backup' subcommand not recognized"
    exit 1
fi

# 4. Test unknown command
echo "Test 4: Unknown command"
output=$("$SCRIPT" unknown_cmd 2>&1 || true)
if [[ "$output" == *"Unknown command: unknown_cmd"* ]]; then
    echo "  - SUCCESS: Correctly identified unknown command"
else
    echo "  - FAILURE: Did not correctly identify unknown command"
    exit 1
fi

# 5. Test archive flag recognition
echo "Test 5: --archive flag recognition"
output=$("$SCRIPT" backup --archive --help 2>&1 || true)
if [[ "$output" == *"Usage: "* ]]; then
    echo "  - SUCCESS: --archive flag recognized in backup command"
else
    echo "  - FAILURE: --archive flag not recognized"
    exit 1
fi

# 6. Test password flag recognition
echo "Test 6: --password flag recognition"
output=$("$SCRIPT" backup --password "testpass" --help 2>&1 || true)
if [[ "$output" == *"Usage: "* ]]; then
    echo "  - SUCCESS: --password flag recognized in backup command"
else
    echo "  - FAILURE: --password flag not recognized"
    exit 1
fi

echo "All tests passed!"
