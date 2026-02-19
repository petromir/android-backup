#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Export to Google Drive utility for android-backup
# ------------------------------------------------------------------------------

SCRIPT_NAME="$(basename "$0")"

print_error() {
    echo "Error: $1" >&2
}

print_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} <zip_file> <gdrive_folder>

Arguments:
  zip_file          Path to the local ZIP file to upload
  gdrive_folder     The destination folder in Google Drive (e.g., "Backups/Android")

Prerequisites:
  This script uses 'rclone' to upload files. You must have rclone installed 
  and configured with a remote named 'gdrive'.
  
  Install rclone:
    macOS: brew install rclone
  
  Configure rclone:
    rclone config (follow prompts to create a 'gdrive' remote)
EOF
}

if [[ $# -lt 2 ]]; then
    print_usage
    exit 1
fi

ZIP_FILE="$1"
GDRIVE_FOLDER="$2"

if [[ ! -f "$ZIP_FILE" ]]; then
    print_error "ZIP file not found: ${ZIP_FILE}"
    exit 1
fi

if ! command -v rclone &>/dev/null; then
    print_error "'rclone' is not installed. Please install it to use Google Drive export."
    echo "  macOS: brew install rclone" >&2
    exit 1
fi

# Check if 'gdrive' remote is configured
if ! rclone listremotes | grep -q "^gdrive:$"; then
    print_error "rclone remote 'gdrive' is not configured."
    echo "  Run 'rclone config' to create a remote named 'gdrive'." >&2
    exit 1
fi

echo "Uploading ${ZIP_FILE} to Google Drive folder: ${GDRIVE_FOLDER}..."

if rclone copy "$ZIP_FILE" "gdrive:${GDRIVE_FOLDER}" --progress; then
    echo "Upload completed successfully."
else
    print_error "Failed to upload to Google Drive."
    exit 1
fi
