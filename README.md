# android-backup

A bash-based backup utility for Android devices using ADB.

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
./android-backup.sh --list-devices
```

Example output:
```
Connected devices:
  - 1A2B3C4D5E6F (device)
  - 192.168.1.100:5555 (device)
```

### Dry run (preview backup)

```bash
./android-backup.sh --backup-folders "/sdcard/DCIM" --output-folder ./backup --dry-run
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
./android-backup.sh --backup-folders "/sdcard/DCIM,/sdcard/Download" --output-folder ./backup
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

### Backup with password-protected archive

```bash
./android-backup.sh --backup-folders "/sdcard/DCIM" --output-folder ./backup --enable-archiving --archiving-password "mypassword"
```

Example output:
```
Starting backup to: ./backup_2026-02-18_130044

[1/1] Copying /sdcard/DCIM...
/sdcard/DCIM/: 15 files pulled, 0 skipped.

Creating encrypted archive...
Backup completed: ./backup_2026-02-18_130044.zip
```

### Show help

```bash
./android-backup.sh --help
```

Example output:
```
Usage: android-backup.sh [OPTIONS]

Options:
  --backup-folders <paths>       Comma-separated list of folders to backup
  --output-folder <path>         Output folder for backup (required for backup)
  --dry-run                      Show what would be backed up without copying
  --enable-archiving             Create a zip archive of the backup
  --archiving-password <pass>    Set password for the archive
  --list-devices                 List connected Android devices
  --help                         Display this help message

Examples:
  android-backup.sh --list-devices
  android-backup.sh --backup-folders "/sdcard/DCIM,/sdcard/Download" --output-folder ./backup --dry-run
  android-backup.sh --backup-folders "/sdcard/DCIM" --output-folder ./backup
  android-backup.sh --backup-folders "/sdcard/DCIM" --output-folder ./backup --enable-archiving --archiving-password "secret"
```

## License

MIT
