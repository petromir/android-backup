# AGENTS.md

This file provides guidance to AI assistances when working with code in this repository.

## Project Overview

**android-backup** - A bash-based backup utility for Android devices using ADB.

- License: MIT
- Language: Bash (strictly)

## Features

- Copy folders from connected Android devices
- Optional archive creation with password protection
- View connected devices

## CLI Parameters

| Parameter | Description |
|-----------|-------------|
| `--backup-folders` | Comma-separated list of folders to backup from device |
| `--output-folder` | Output folder for backup (timestamp appended automatically) |
| `--dry-run` | Show what would be backed up without copying |
| `--enable-archiving` | Enable zip archive creation |
| `--archiving-password` | Password for the archive (requires `--enable-archiving`) |
| `--list-devices` | List currently connected Android devices |
| `--help` | Show usage information |

## Dependencies

- `adb` (Android Debug Bridge)
- `zip` (for archiving with password)

## Bash Scripting Guidelines

### Required Practices

- Start scripts with `#!/usr/bin/env bash`
- Enable strict mode: `set -euo pipefail`
- Quote all variable expansions: `"$var"` not `$var`
- Use `[[ ]]` for conditionals (not `[ ]`)
- Use `$(command)` for command substitution (not backticks)
- Declare local variables in functions: `local var="value"`

### Error Handling

- Validate all user inputs before processing
- Check command exit codes and handle failures
- Provide clear error messages with context
- Use `trap` for cleanup on script exit
- Verify ADB connection before operations

### Code Style

- Use snake_case for variables and functions
- Use UPPER_CASE for constants/environment variables
- Add comments for non-obvious logic
- Keep functions focused and single-purpose
