#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ------------------------------------------------------------------------------
# Test script for android-backup.sh subcommand refactoring
# ------------------------------------------------------------------------------

finish() {
    local result=${?}
    exit ${result}
}
trap finish EXIT ERR

SCRIPT="./android-backup.sh"

printf "Running tests for android-backup.sh subcommands...\n"

# 1. Test help output
printf "Test 1: Help output\n"
if grep -q "Commands:" < <("${SCRIPT}" --help); then
    printf "  - SUCCESS: Help contains 'Commands:'\n"
else
    printf "  - FAILURE: Help does not contain 'Commands:'\n"
    exit 1
fi

# 2. Test devices subcommand
printf "Test 2: 'devices' subcommand\n"
output=$("${SCRIPT}" devices 2>&1 || true)
if [[ "${output}" == *"No devices connected"* ]] || [[ "${output}" == *"Connected devices:"* ]] || [[ "${output}" == *"adb is not installed"* ]] || [[ "${output}" == *"Failed to connect to ADB server"* ]]; then
    printf "  - SUCCESS: 'devices' subcommand recognized\n"
else
    printf "  - FAILURE: 'devices' subcommand not recognized (Result: %s)\n" "${output}"
    exit 1
fi

# 3. Test backup subcommand (should fail if params are missing)
printf "Test 3: 'backup' subcommand validation\n"
# We expect this to fail with either a device error OR a validation error
# But we specifically want to see if the command 'backup' is recognized
output=$("${SCRIPT}" backup --help 2>&1 || true)
if [[ "${output}" == *"Usage: "* ]]; then
    printf "  - SUCCESS: 'backup' subcommand recognized help\n"
else
    printf "  - FAILURE: 'backup' subcommand not recognized\n"
    exit 1
fi

# 4. Test unknown command
printf "Test 4: Unknown command\n"
output=$("${SCRIPT}" unknown_cmd 2>&1 || true)
if [[ "${output}" == *"Unknown command: unknown_cmd"* ]]; then
    printf "  - SUCCESS: Correctly identified unknown command\n"
else
    printf "  - FAILURE: Did not correctly identify unknown command\n"
    exit 1
fi

# 5. Test archive flag recognition
printf "Test 5: --archive flag recognition\n"
output=$("${SCRIPT}" backup --archive --help 2>&1 || true)
if [[ "${output}" == *"Usage: "* ]]; then
    printf "  - SUCCESS: --archive flag recognized in backup command\n"
else
    printf "  - FAILURE: --archive flag not recognized\n"
    exit 1
fi

# 6. Test password flag recognition
printf "Test 6: --password flag recognition\n"
output=$("${SCRIPT}" backup --password "testpass" --help 2>&1 || true)
if [[ "${output}" == *"Usage: "* ]]; then
    printf "  - SUCCESS: --password flag recognized in backup command\n"
else
    printf "  - FAILURE: --password flag not recognized\n"
    exit 1
fi

printf "All tests passed!\n"
