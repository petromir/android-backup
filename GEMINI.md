# GEMINI.md - Android Backup Utility

This file provides foundational context and instructions for Gemini CLI when working on the `android-backup` project.

## Project Overview

**android-backup** is a Bash-based utility for backing up folders from Android devices via ADB.

- **License:** MIT
- **Primary Language:** Bash (Strict Mode)
- **Target OS:** macOS/Linux (Bash environments)

## Features

- Recursive folder copy from connected Android devices.
- Optional password-protected ZIP archive creation.
- Device discovery and selection.
- Dry-run capability.

## Technical Standards & Conventions

### Bash Scripting
- **Strict Mode:** Always use `set -euo pipefail`.
- **Environment:** Use `#!/usr/bin/env bash` for the shebang.
- **Scoping:** Use `local` for all variables inside functions.
- **Conditionals:** Prefer `[[ ... ]]` over `[ ... ]`.
- **Naming:** 
    - Variables/Functions: `snake_case`.
    - Constants/Env: `UPPER_SNAKE_CASE`.
- **Quotes:** Rigorously quote all expansions: `"$var"`.

### ADB & Android
- **Connection Check:** Always verify device connectivity before attempting pull operations.
- **Path Handling:** Be mindful of Unix-style paths on Android vs. local paths.
- **Error Handling:** Check `adb` exit codes; a zero exit code doesn't always mean success (e.g., "file not found" on some ADB versions).

## Operational Instructions
- **Validation:** When modifying `android-backup.sh`, ensure you don't break compatibility with older `adb` versions if possible.
- **Testing:** Since this interacts with hardware (Android devices), prioritize "Dry Run" logic and unit tests for internal string/path manipulation functions.
