#!/bin/bash
SENTINEL_FILE="prd-sentinel.json"
LOG_FILE="hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if [ ! -f "$SENTINEL_FILE" ]; then
  echo "[$TIMESTAMP] FAIL: $SENTINEL_FILE not found" | tee -a "$LOG_FILE"
  exit 1
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
  echo "[$TIMESTAMP] PASS: PRD validation passed. Sections: $SECTIONS. Word count: $WORD_COUNT." | tee -a "$LOG_FILE"
  echo "$TIMESTAMP" > "proceed-to-architecture.flag"
  echo "[$TIMESTAMP] GO: Trigger file written." | tee -a "$LOG_FILE"
  exit 0
else
  echo "[$TIMESTAMP] FAIL: Validation failed ($FAIL_COUNT issues)" | tee -a "$LOG_FILE"
  exit 1
fi
