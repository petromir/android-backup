# AGENTS.md

This file provides guidance to AI assistances when working with code in this repository.

## Project Overview

**android-backup** - A bash-based backup utility for Android devices using ADB.

- License: MIT
- Language: Bash (strictly)
- Target OS: macOS/Linux (Bash environments)

## Features

- Recursive folder copy from connected Android devices.
- Optional archive creation with password protection
- Export to Google Drive (using rclone)
- View connected devices
- Dry-run capability.

## Command Structure

The utility uses a subcommand-based interface:

- `devices`: List currently connected Android devices.
- `backup [options]`: Perform a backup from the connected device.

## Backup Parameters

| Parameter | Description |
|-----------|-------------|
| `--folders <paths>` | Comma-separated list of folders to backup from device (required) |
| `--output <path>` | Output folder for backup (timestamp appended automatically) (required) |
| `--dry-run` | Show what would be backed up without copying |
| `--archive` | Enable zip archive creation |
| `--password <pass>` | Password for the archive (requires `--archive`) |
| `--help, -h` | Show usage information |

## Google Drive Export Utility

The `export-gdrive.sh` script is a standalone utility to upload files to Google Drive.

Usage: `./export-gdrive.sh <zip_file> <gdrive_folder>`

| Argument | Description |
|----------|-------------|
| `zip_file` | Path to the local ZIP file to upload |
| `gdrive_folder` | The destination folder in Google Drive |

## Dependencies

- `adb` (Android Debug Bridge)
- `zip` (for archiving with password)
- `rclone` (optional, for Google Drive export)

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
