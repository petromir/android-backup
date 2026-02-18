#!/usr/bin/env bash
set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")

# Global variables
BACKUP_FOLDERS=""
OUTPUT_FOLDER=""
DRY_RUN=false
ENABLE_ARCHIVING=false
ARCHIVING_PASSWORD=""

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------

print_error() {
    echo "Error: $1" >&2
}

print_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} COMMAND [OPTIONS]

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
  ${SCRIPT_NAME} devices
  ${SCRIPT_NAME} backup --folders "/sdcard/DCIM" --output ./backup --dry-run
  ${SCRIPT_NAME} backup --folders "/sdcard/DCIM,/sdcard/Download" --output ./backup --archive
EOF
}

check_adb_installed() {
    if ! command -v adb &>/dev/null; then
        print_error "adb is not installed. Please install Android Platform Tools."
        echo "  macOS: brew install android-platform-tools" >&2
        exit 1
    fi
}

check_device_connected() {
    local device_count
    device_count=$(adb devices 2>&1 | grep -cE $'\t(device)$' || true)
    
    if [[ "$device_count" -eq 0 ]]; then
        print_error "No authorized device connected. Please connect a device and authorize USB debugging."
        exit 1
    elif [[ "$device_count" -gt 1 ]]; then
        print_error "Multiple devices connected. Please connect only one device."
        exit 1
    fi
}

format_size() {
    local bytes=$1
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1073741824}") GB"
    elif [[ $bytes -ge 1048576 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}") MB"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1024}") KB"
    else
        echo "${bytes} B"
    fi
}

validate_backup_params() {
    if [[ -z "$BACKUP_FOLDERS" ]]; then
        print_error "--folders is required."
        exit 1
    fi
    
    if [[ -z "$OUTPUT_FOLDER" ]]; then
        print_error "--output is required."
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Command functions
# ------------------------------------------------------------------------------

list_folder_contents() {
    local folder=$1
    local total_size=0
    local file_count=0
    
    echo ""
    echo "Folder: ${folder}"
    echo "$(printf '=%.0s' {1..60})"
    printf -- "%-40s %10s %s\n" "File" "Size" "Modified"
    echo "$(printf '-%.0s' {1..60})"
    
    # Get file listing from device
    local ls_output
    if ! ls_output=$(adb shell "ls -la \"${folder}\" 2>/dev/null" 2>&1); then
        print_error "Cannot access folder: ${folder}"
        return 1
    fi
    
    # Parse ls output (skip . and .. entries and total line)
    while IFS= read -r line; do
        # Skip empty lines, total line, and . / .. entries
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^total ]] && continue
        [[ "$line" =~ \.$ ]] && continue
        [[ "$line" =~ \.\.$ ]] && continue
        
        # Parse ls -la output: permissions, links, owner, group, size, date, time, name
        local size date time name
        size=$(echo "$line" | awk '{print $5}')
        date=$(echo "$line" | awk '{print $6}')
        time=$(echo "$line" | awk '{print $7}')
        name=$(echo "$line" | awk '{for(i=8;i<=NF;i++) printf $i" "; print ""}'| sed 's/ *$//')
        
        # Skip if we couldn't parse properly
        [[ -z "$name" ]] && continue
        
        # Handle directories (size shown as -)
        if [[ "$line" =~ ^d ]]; then
            printf -- "%-40s %10s %s\n" "${name}/" "<DIR>" "${date} ${time}"
        else
            if [[ "$size" =~ ^[0-9]+$ ]]; then
                total_size=$((total_size + size))
                file_count=$((file_count + 1))
            fi
            printf -- "%-40s %10s %s\n" "$name" "$(format_size "$size")" "${date} ${time}"
        fi
    done <<< "$ls_output"
    
    echo "$(printf '-%.0s' {1..60})"
    echo "Summary: ${file_count} files, $(format_size $total_size)"
}

backup_folders() {
    check_adb_installed
    check_device_connected
    validate_backup_params
    
    local output_dir="${OUTPUT_FOLDER}_${TIMESTAMP}"
    
    # Convert comma-separated list to array
    IFS=',' read -ra folders <<< "$BACKUP_FOLDERS"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "=== DRY RUN MODE ==="
        echo "Output would be: ${output_dir}"
        echo ""
        echo "Files to backup:"
        
        for folder in "${folders[@]}"; do
            # Trim whitespace
            folder=$(echo "$folder" | xargs)
            list_folder_contents "$folder" || true
        done
        
        echo ""
        echo "=== END DRY RUN ==="
        return 0
    fi
    
    # Create output directory
    if ! mkdir -p "$output_dir"; then
        print_error "Failed to create output directory: ${output_dir}"
        exit 1
    fi
    
    echo "Starting backup to: ${output_dir}"
    echo ""
    
    local total_folders=${#folders[@]}
    local current=0
    
    for folder in "${folders[@]}"; do
        folder=$(echo "$folder" | xargs)
        current=$((current + 1))
        
        echo "[${current}/${total_folders}] Copying ${folder}..."
        
        # Get the folder name for local path
        local folder_name
        folder_name=$(basename "$folder")
        local local_path="${output_dir}/${folder_name}"
        
        # Pull folder from device
        if ! adb pull "$folder" "$local_path" 2>&1 | tail -1; then
            print_error "Failed to copy: ${folder}"
            continue
        fi
    done
    
    echo ""
    echo "Backup completed: ${output_dir}"

    if [[ "$ENABLE_ARCHIVING" == true ]]; then
        if ! command -v zip &>/dev/null; then
            print_error "'zip' is not installed. Skipping archive creation."
            return 0
        fi

        local archive_name="${output_dir}.zip"
        echo "Creating archive: ${archive_name}..."
        
        # Change to the parent directory of output_dir to have cleaner paths in zip
        local parent_dir
        parent_dir=$(dirname "$output_dir")
        local base_dir
        base_dir=$(basename "$output_dir")
        
        local zip_cmd=("zip" "-r")
        if [[ -n "$ARCHIVING_PASSWORD" ]]; then
            zip_cmd+=("-P" "$ARCHIVING_PASSWORD")
            echo "Using password protection for archive."
        fi
        zip_cmd+=("${base_dir}.zip" "$base_dir")

        if (cd "$parent_dir" && "${zip_cmd[@]}" > /dev/null); then
            echo "Archive created successfully."
            # Optionally remove the uncompressed folder
            rm -rf "$output_dir"
            echo "Uncompressed backup folder removed."
        else
            print_error "Failed to create archive."
        fi
    fi
}

list_devices() {
    check_adb_installed

    local devices_output
    if ! devices_output=$(adb devices 2>&1); then
        print_error "Failed to connect to ADB server."
        exit 1
    fi

    # Parse device list: extract lines with device/unauthorized/offline status
    # This filters out daemon messages and the "List of devices attached" header
    local device_lines
    device_lines=$(echo "$devices_output" | grep -E $'\t(device|unauthorized|offline)$' || true)

    if [[ -z "$device_lines" ]]; then
        echo "No devices connected."
        return 0
    fi

    echo "Connected devices:"
    while IFS=$'\t' read -r device_id status; do
        if [[ -n "$device_id" ]]; then
            echo "  - ${device_id} (${status})"
        fi
    done <<< "$device_lines"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

main() {
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        devices)
            list_devices
            ;;
        backup)
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --folders)
                        if [[ -z "${2:-}" || "$2" == --* ]]; then
                            print_error "--folders requires a value."
                            exit 1
                        fi
                        BACKUP_FOLDERS="$2"
                        shift 2
                        ;;
                    --output)
                        if [[ -z "${2:-}" || "$2" == --* ]]; then
                            print_error "--output requires a value."
                            exit 1
                        fi
                        OUTPUT_FOLDER="$2"
                        shift 2
                        ;;
                    --dry-run)
                        DRY_RUN=true
                        shift
                        ;;
                    --archive)
                        ENABLE_ARCHIVING=true
                        shift
                        ;;
                    --password)
                        if [[ -z "${2:-}" || "$2" == --* ]]; then
                            print_error "--password requires a value."
                            exit 1
                        fi
                        ARCHIVING_PASSWORD="$2"
                        shift 2
                        ;;
                    --help|-h)
                        print_usage
                        exit 0
                        ;;
                    *)
                        print_error "Unknown backup option: $1"
                        print_usage
                        exit 1
                        ;;
                esac
            done
            backup_folders
            ;;
        --help|-h|help)
            print_usage
            exit 0
            ;;
        *)
            print_error "Unknown command: $command"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
