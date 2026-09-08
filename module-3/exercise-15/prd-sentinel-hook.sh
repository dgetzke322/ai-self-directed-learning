#!/bin/bash
#
# prd-sentinel-hook.sh — Validates PRD sentinel file for governed flow
#
# TRIGGER EVENT: PostToolUse Write event on any file write in the working directory
#   (configured in ~/.claude/settings.json hooks.PostToolUse)
#
# PURPOSE: Validate prd-sentinel.json against the governance schema after PRD generation
#
# DECISION LOGIC:
#   1. Check if prd-sentinel.json file exists
#      - If missing: SKIP (sentinel not yet written by skill, wait for next write)
#      - If present: VALIDATE
#
#   2. When present, validate against schema:
#      - All 9 PRD sections must be present (checked via keyword grep)
#      - Word count must be in range (~500-3000)
#      - has_measurable_success_criteria must be true
#      - has_explicit_out_of_scope must be true
#
# SUCCESS ACTION:
#   - Log validation passed with section count and word count
#   - Write proceed-to-architecture.flag (timestamp)
#   - Exit with code 0 (success)
#   - Triggers architecture-trigger-hook to detect flag and queue next step
#
# FAILURE ACTION:
#   - Log validation failed with count of issues found
#   - Do NOT write proceed-to-architecture.flag
#   - Exit with code 1 (failure)
#   - Governance gate blocks progression until PRD is fixed
#
# SCHEMA REFERENCE: See create-prd-sentinel-schema.md for full sentinel schema
#

SENTINEL_FILE="prd-sentinel.json"
LOG_FILE="hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if [ ! -f "$SENTINEL_FILE" ]; then
  echo "[$TIMESTAMP] SKIP: $SENTINEL_FILE not yet present (waiting for skill to write it)" | tee -a "$LOG_FILE"
  exit 0
fi
SECTIONS=$(jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
WORD_COUNT=$(jq -r '.word_count' "$SENTINEL_FILE" 2>/dev/null)
HAS_SUCCESS_CRITERIA=$(jq -r '.has_measurable_success_criteria' "$SENTINEL_FILE" 2>/dev/null)
HAS_OUT_OF_SCOPE=$(jq -r '.has_explicit_out_of_scope' "$SENTINEL_FILE" 2>/dev/null)
FAIL_COUNT=0
if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "problem\|overview"; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "requirement"; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "success\|metric"; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "scope\|boundary"; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if [ "$HAS_SUCCESS_CRITERIA" != "true" ]; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if [ "$HAS_OUT_OF_SCOPE" != "true" ]; then FAIL_COUNT=$((FAIL_COUNT + 1)); fi
if [ $FAIL_COUNT -eq 0 ]; then
  echo "[$TIMESTAMP] PASS: Validated $SENTINEL_FILE - Sections: $SECTIONS. Word count: $WORD_COUNT." | tee -a "$LOG_FILE"
  TRIGGER_FILE="proceed-to-architecture.flag"
  echo "$TIMESTAMP" > "$TRIGGER_FILE"
  echo "[$TIMESTAMP] WRITE: $TRIGGER_FILE" | tee -a "$LOG_FILE"
  exit 0
else
  echo "[$TIMESTAMP] FAIL: Validation of $SENTINEL_FILE failed ($FAIL_COUNT issues)" | tee -a "$LOG_FILE"
  exit 1
fi
