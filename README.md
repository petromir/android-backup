# android-data-backup

A bash-based backup utility for Android devices using ADB. In essence, it copies and zips (optionally with a password) specified folders, along with an option to export files to Google Drive.

## Prerequisites

### macOS Installation

```bash
# Install ADB via Homebrew
brew install android-platform-tools
```

```bash
# Install zip (usually pre-installed on macOS)
brew install zip
```

```bash
# Optional: Install gws (Google Workspace CLI) for Google Drive export
brew install googleworkspace-cli
```

### Device Setup

1. Enable USB debugging on your Android device (Settings > Developer Options > USB Debugging)
2. Connect your device via USB
3. Authorize the connection when prompted on your device

## Installation

```bash
git clone https://github.com/your-username/android-backup.git
cd android-backup
chmod +x android-backup.sh
```

## Usage

### List connected devices

```bash
./android-backup.sh devices
```

Example output:
```
Connected devices:
  - 1A2B3C4D5E6F (device)
  - 192.168.1.100:5555 (device)
```

### Dry run (preview backup)

```bash
./android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --dry-run
```

Example output:
```
=== DRY RUN MODE ===
Output would be: ./backup_2026-02-18_130044

Files to backup:

Folder: /sdcard/DCIM
============================================================
File                                           Size Modified
------------------------------------------------------------
Camera/                                       <DIR> 2026-02-15 10:30
IMG_20260215_103045.jpg                      3.5 MB 2026-02-15 10:30
IMG_20260216_142233.jpg                      4.2 MB 2026-02-16 14:22
------------------------------------------------------------
Summary: 2 files, 7.70 MB

=== END DRY RUN ===
```

### Backup specific folders

```bash
./android-backup.sh backup --folders "/sdcard/DCIM,/sdcard/Download" --output ./backup
```

Example output:
```
Starting backup to: ./backup_2026-02-18_130044

[1/2] Copying /sdcard/DCIM...
/sdcard/DCIM/: 15 files pulled, 0 skipped.
[2/2] Copying /sdcard/Download...
/sdcard/Download/: 8 files pulled, 0 skipped.

Backup completed: ./backup_2026-02-18_130044
```

### Backup with archive

```bash
./android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --archive
```

Example output:
```
Starting backup to: ./backup_2026-02-18_130044

[1/1] Copying /sdcard/DCIM...
/sdcard/DCIM/: 15 files pulled, 0 skipped.

Backup completed: ./backup_2026-02-18_130044
Creating archive: ./backup_2026-02-18_130044.zip...
Archive created successfully.
Uncompressed backup folder removed.
```

### Backup with password-protected archive

```bash
./android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --archive --password "mypassword"
```

Example output:
```
Starting backup to: ./backup_2026-02-18_130044

[1/1] Copying /sdcard/DCIM...
/sdcard/DCIM/: 15 files pulled, 0 skipped.

Backup completed: ./backup_2026-02-18_130044
Creating archive: ./backup_2026-02-18_130044.zip...
Using password protection for archive.
Archive created successfully.
Uncompressed backup folder removed.
```

### Export to Google Drive

Use the `export-gdrive.sh` script to upload a backup archive to Google Drive. This script requires `gws` (Google Workspace CLI) to be installed and authenticated.

**1. Install `gws`:**
```bash
brew install googleworkspace-cli
# or: npm install -g @googleworkspace/cli
```

**2. Authenticate:**
```bash
gws auth setup   # one-time setup
gws auth login   # log in to Google
```

**3. Upload:**
```bash
./export-gdrive.sh ./backup_2026-02-18_130044.zip "YOUR_FOLDER_ID"
```

> **Note:** The second argument must be a Google Drive **folder ID**, not a folder name. To find it, open the folder in Google Drive web UI and copy the ID from the URL (`https://drive.google.com/drive/folders/FOLDER_ID`).

Example output:
```
Uploading ./backup_2026-02-18_130044.zip to Google Drive folder ID: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms...
Upload completed successfully.
```

### Chained backup and upload

You can chain `android-backup.sh` and `export-gdrive.sh` into a single command to back up, archive, and upload in one go.

**Basic one-liner (uses the most recent zip in the directory):**

```bash
./android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --archive && \
  ./export-gdrive.sh "$(ls -t ./backup_*.zip | head -n 1)" "YOUR_FOLDER_ID"
```

**With password protection:**

```bash
./android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --archive --password && \
  ./export-gdrive.sh "$(ls -t ./backup_*.zip | head -n 1)" "YOUR_FOLDER_ID"
```

**How it works:**

1. `android-backup.sh` creates a timestamped archive (e.g. `./backup_2026-02-18_130044.zip`).
2. `ls -t ./backup_*.zip | head -n 1` picks the newest zip file in the current directory.
3. `export-gdrive.sh` uploads that file to the specified Google Drive folder.
4. `&&` ensures the upload only runs if the backup succeeds.

> **Tip:** Run this from a dedicated backup directory (or use `--output /path/to/backups`) so `ls -t` only sees your latest backup.

### Show help

```bash
./android-backup.sh --help
```

Example output:
```
Usage: android-backup.sh COMMAND [OPTIONS]

Commands:
  devices                        List connected Android devices
  backup [OPTIONS]               Backup folders from the connected device

Backup Options:
  --folders <paths>              Comma-separated list of folders to backup (required)
  --output <path>                Output folder for backup (required)
  --dry-run                      Show what would be backed up without copying
  --archive                      Create a zip archive of the backup
  --password <pass>              Set password for the archive

Global Options:
  --help, -h                     Display this help message

Examples:
  android-backup.sh devices
  android-backup.sh backup --folders "/sdcard/DCIM" --output ./backup --dry-run
  android-backup.sh backup --folders "/sdcard/DCIM,/sdcard/Download" --output ./backup --archive
```

## Development & Contributing

Contributions are more than welcome! Please follow the guidelines in [CONTRIBUTING.md](CONTRIBUTING.md)

### The `finish` function

Every script declares a `finish` function paired with a `trap`:

```bash
finish() {
    local result=${?}
    # Cleanup code goes here (e.g. rm -f "${tmpfile}")
    exit ${result}
}
trap finish EXIT ERR
```

This pattern ensures that:
1. **Cleanup runs on any exit path** — whether the script succeeds, fails, or is interrupted.
2. **The original exit code is preserved** — `local result=${?}` captures the exit status *before* any cleanup commands execute, so the script returns the same code it would have returned without the trap.

Currently, the `finish` function is a no-op placeholder; it exists so that future cleanup (temporary files, 
unmounting a drive, kill a backgroud process, restore terminal settings, etc.) can be added in one central location 
without risk of leaking resources or masking failure codes.

## License

[MIT](LICENSE)
