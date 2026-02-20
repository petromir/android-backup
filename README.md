# android-data-backup

A bash-based backup utilities for Android devices using ADB. In essence it copies and zips (optionally with a password) specified folders, along with an option to export files to Google Drive.

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
# Optional: Install rclone for Google Drive export
brew install rclone
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

Use the `export-gdrive.sh` script to upload a backup archive to Google Drive. This script requires `rclone` to be configured (see [here](https://rclone.org/drive/#making-your-own-client-id) and [here](https://rclone.org/drive/)) with a remote named `gdrive`.

```bash
./export-gdrive.sh ./backup_2026-02-18_130044.zip "AndroidBackups"
```

Example output:
```
Uploading ./backup_2026-02-18_130044.zip to Google Drive folder: AndroidBackups...
Upload completed successfully.
```

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

## License

[MIT](LICENSE)
