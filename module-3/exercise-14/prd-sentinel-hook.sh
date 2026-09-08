#!/bin/bash
# prd-sentinel-hook.sh - Exercise 14, Step 4
# Validates prd-sentinel.json against the schema
# Reads sentinel file, checks required properties, logs results, exits 0 or 1

SENTINEL_FILE="prd-sentinel.json"
LOG_FILE="hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Check if sentinel file exists
if [ ! -f "$SENTINEL_FILE" ]; then
  echo "[$TIMESTAMP] FAIL: $SENTINEL_FILE not found" | tee -a "$LOG_FILE"
  exit 1
fi

# Parse JSON using jq
SECTIONS=$(jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
WORD_COUNT=$(jq -r '.word_count' "$SENTINEL_FILE" 2>/dev/null)
HAS_SUCCESS_CRITERIA=$(jq -r '.has_measurable_success_criteria' "$SENTINEL_FILE" 2>/dev/null)
HAS_OUT_OF_SCOPE=$(jq -r '.has_explicit_out_of_scope' "$SENTINEL_FILE" 2>/dev/null)
HAS_ASSUMPTIONS=$(jq -r '.has_assumptions_section' "$SENTINEL_FILE" 2>/dev/null)

# Track failures
FAIL_COUNT=0

# Validate required sections (must include overview, requirements, success_criteria, and scope section)
# The scope section may be named "scope_and_boundaries" or "out_of_scope"
REQUIRED_SECTIONS=("overview" "requirements" "success_criteria")
for section in "${REQUIRED_SECTIONS[@]}"; do
  if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "^$section"; then
    echo "[$TIMESTAMP] FAIL: Missing required section: $section" | tee -a "$LOG_FILE"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

# Check for scope section (by either name)
if ! jq -r '.sections_present[]?' "$SENTINEL_FILE" 2>/dev/null | grep -qi "scope"; then
  echo "[$TIMESTAMP] FAIL: Missing scope section (out_of_scope or scope_and_boundaries)" | tee -a "$LOG_FILE"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Validate word count (warn if outside 500-3000, don't fail)
if [ "$WORD_COUNT" != "null" ] && [ -n "$WORD_COUNT" ]; then
  if [ "$WORD_COUNT" -lt 500 ] || [ "$WORD_COUNT" -gt 3000 ]; then
    echo "[$TIMESTAMP] WARN: Word count ($WORD_COUNT) outside recommended range (500-3000)" | tee -a "$LOG_FILE"
  fi
else
  echo "[$TIMESTAMP] FAIL: word_count field missing or invalid" | tee -a "$LOG_FILE"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Validate measurable success criteria (required, halt if false)
if [ "$HAS_SUCCESS_CRITERIA" != "true" ]; then
  echo "[$TIMESTAMP] FAIL: PRD missing measurable success criteria" | tee -a "$LOG_FILE"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Validate explicit out-of-scope section (required, halt if false)
if [ "$HAS_OUT_OF_SCOPE" != "true" ]; then
  echo "[$TIMESTAMP] FAIL: PRD missing explicit out-of-scope section" | tee -a "$LOG_FILE"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Validate assumptions section (warn if missing)
if [ "$HAS_ASSUMPTIONS" != "true" ]; then
  echo "[$TIMESTAMP] WARN: PRD missing assumptions section (recommended but not required)" | tee -a "$LOG_FILE"
fi

# Report final status
if [ $FAIL_COUNT -eq 0 ]; then
  echo "[$TIMESTAMP] PASS: PRD sentinel validation passed. Sections: $SECTIONS. Word count: $WORD_COUNT." | tee -a "$LOG_FILE"
  exit 0
else
  echo "[$TIMESTAMP] FAIL: PRD sentinel validation failed ($FAIL_COUNT issues)" | tee -a "$LOG_FILE"
  exit 1
fi
