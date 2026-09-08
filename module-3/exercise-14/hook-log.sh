#!/bin/bash
# hook-log.sh - Hello World Hook for Exercise 14, Step 1
# Logs every file write to hook-log.txt
#
# Called by Claude Code's PostToolUse hook with JSON on stdin

LOG_FILE="module-3/exercise-14/hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$DEBUG_LOG")"

# Read JSON from stdin
HOOK_INPUT=$(cat)

# Extract tool name and file path from JSON
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)

# Try multiple possible paths for file location
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input // "unknown"' 2>/dev/null)

echo "[$TIMESTAMP] Tool: $TOOL_NAME, File: $FILE_PATH" >> "$LOG_FILE"
exit 0
