#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# ------------------------------------------------------------------------------
# Export to Google Drive utility for android-backup
# Uses gws (Google Workspace CLI).
# ------------------------------------------------------------------------------

finish() {
    local result=${?}
    exit ${result}
}
trap finish EXIT ERR

SCRIPT_NAME="$(basename "${0}")"

print_error() {
    printf "Error: %s\n" "${1}" >&2
}

print_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} <zip_file|- > <gdrive_folder_id>

Arguments:
  zip_file          Path to the local ZIP file to upload, or - to read the
                    path from standard input (useful for piping)
  gdrive_folder_id  The destination Google Drive folder ID

Prerequisites:
  This script uses 'gws' (Google Workspace CLI) to upload files.
  You must have gws installed and authenticated.

  Install gws:
    macOS: brew install googleworkspace-cli
    Or:   npm install -g @googleworkspace/cli

  Authenticate gws:
    gws auth setup   # one-time setup
    gws auth login   # log in to Google

  Find a folder ID:
    Open the target folder in Google Drive web UI.
    The URL will look like: https://drive.google.com/drive/folders/FOLDER_ID

Examples:
  ${SCRIPT_NAME} ./backup_2026-02-18_130044.zip "YOUR_FOLDER_ID"
  echo "./backup_2026-02-18_130044.zip" | ${SCRIPT_NAME} - "YOUR_FOLDER_ID"
EOF
}

if [[ ${#} -lt 2 ]]; then
    print_usage
    exit 1
fi

ZIP_FILE="${1}"
GDRIVE_FOLDER="${2}"

# Support reading the file path from stdin when - is given
if [[ "${ZIP_FILE}" == "-" ]]; then
    if ! read -r ZIP_FILE; then
        print_error "No file path received on standard input."
        exit 1
    fi
fi

if [[ ! -f "${ZIP_FILE}" ]]; then
    print_error "ZIP file not found: ${ZIP_FILE}"
    exit 1
fi

if ! command -v gws &>/dev/null; then
    print_error "'gws' is not installed. Please install it to use Google Drive export."
    printf "  macOS: brew install googleworkspace-cli\n" >&2
    printf "  Or:   npm install -g @googleworkspace/cli\n" >&2
    exit 1
fi

# Verify gws authentication with a lightweight Drive API call
if ! gws drive about get --params '{"fields": "user"}' &>/dev/null; then
    print_error "gws authentication failed or Google Drive API is not accessible."
    printf "  Please run: gws auth setup   # one-time setup\n" >&2
    printf "  Then run:   gws auth login   # log in to Google\n" >&2
    exit 1
fi

printf "Uploading %s to Google Drive folder ID: %s...\n" "${ZIP_FILE}" "${GDRIVE_FOLDER}"

if gws drive +upload "${ZIP_FILE}" --parent "${GDRIVE_FOLDER}"; then
    printf "Upload completed successfully.\n"
else
    print_error "Failed to upload to Google Drive."
    exit 1
fi
