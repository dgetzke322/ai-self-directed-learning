#!/bin/bash
# hook-log.sh - Hello World Hook for Exercise 14, Step 1
# Logs every file write to hook-log.txt
#
# Called by Claude Code's PostToolUse hook with JSON on stdin

LOG_FILE="module-3/exercise-14/hook-log.txt"
DEBUG_LOG="module-3/exercise-14/hook-debug.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$DEBUG_LOG")"

# Read JSON from stdin
HOOK_INPUT=$(cat)

# Log debug info
{
  echo "[$TIMESTAMP] Hook invoked"
  echo "Input: $(echo "$HOOK_INPUT" | jq -c '.' 2>/dev/null || echo "$HOOK_INPUT")"
  echo "---"
} >> "$DEBUG_LOG"

# Extract tool name and file path from JSON
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)

# Try multiple possible paths for file location
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input // "unknown"' 2>/dev/null)

echo "[$TIMESTAMP] Tool: $TOOL_NAME, File: $FILE_PATH" >> "$LOG_FILE"
exit 0
