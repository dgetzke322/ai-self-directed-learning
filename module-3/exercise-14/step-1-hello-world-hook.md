# Step 1: Hello World Hook

**Exercise 14, Step 1: Verify Hook Mechanism Works**

**Time:** 30 minutes  
**Goal:** Create and test a basic hook that logs file writes

---

## What You're Building

A simple hook that:
- Fires when ANY file is written
- Logs the filename + timestamp to `hook-log.txt`
- Verifies the hook mechanism works at all

This is a "smoke test" before building production hook logic.

---

## Hook Configuration (Claude Code)

Claude Code hooks are configured in `.claude/settings.json`. Hooks watch for file writes and can execute shell scripts in response.

**Configuration Structure:**

```json
{
  "hooks": {
    "afterFileWrite": {
      "script": "./hook-log.sh",
      "runInBackground": true
    }
  }
}
```

**What this means:**
- `afterFileWrite`: Hook fires when any file is written
- `script`: Path to the shell script to run
- `runInBackground`: Don't block the editor (run async)

**Steps to configure:**
1. Check if `.claude/settings.json` exists in your workspace
   ```bash
   ls -la .claude/settings.json
   ```

2. If it doesn't exist, create it:
   ```bash
   mkdir -p .claude
   touch .claude/settings.json
   ```

3. Add or update the hook configuration (see template below)

---

## Hello World Hook Script

Create `hook-log.sh` in the exercise-14 directory:

```bash
#!/bin/bash
# hook-log.sh - Hello World Hook
# Logs every file write to hook-log.txt

LOG_FILE="module-3/exercise-14/hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FILENAME="$1"  # File that was written (passed by hook)

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log the event
echo "[$TIMESTAMP] File written: $FILENAME" >> "$LOG_FILE"

exit 0
```

**Save as:** `module-3/exercise-14/hook-log.sh`

**Make executable:**
```bash
chmod +x module-3/exercise-14/hook-log.sh
```

---

## Test the Hook

### Test 1: Manual Script Test

Run the script directly to verify it works:

```bash
./module-3/exercise-14/hook-log.sh "test-file.txt"
cat module-3/exercise-14/hook-log.txt
```

**Expected output:**
```
[2026-09-08T14:23:45Z] File written: test-file.txt
```

### Test 2: Automatic Hook Test

1. Ensure `.claude/settings.json` has the hook configured
2. Create a test file in your workspace:
   ```bash
   echo "test content" > test-hook-trigger.md
   ```
3. Wait 2-3 seconds for the hook to fire
4. Check if `hook-log.txt` was updated:
   ```bash
   cat module-3/exercise-14/hook-log.txt
   ```

**Expected:** The test file write should appear in the log

### Test 3: Verify Multiple Writes

Create several files and verify they all log:

```bash
echo "file 1" > test1.txt
echo "file 2" > test2.md
echo "file 3" > test3.json
sleep 2
cat module-3/exercise-14/hook-log.txt
```

**Expected:** All three files logged with timestamps

---

## Troubleshooting

### Issue: hook-log.txt is empty or not created

**Possible causes:**
1. Hook not configured in `.claude/settings.json`
   - Solution: Add hook configuration (see above)

2. Script path wrong in configuration
   - Solution: Use absolute or correct relative path

3. Script not executable
   - Solution: `chmod +x module-3/exercise-14/hook-log.sh`

4. Log file path wrong in script
   - Solution: Verify `LOG_FILE` path in script

**Debug step:**
- Manually run the script: `./module-3/exercise-14/hook-log.sh "debug-test.txt"`
- Check if it created the log file
- If not, check permissions and paths

### Issue: Hook fires but writes wrong format

**Check:**
- Is `TIMESTAMP` being captured correctly?
- Is `FILENAME` passed to the script?
- Is the log file in the right location?

---

## Success Criteria

✅ Step 1 is complete when:

1. ✅ `.claude/settings.json` exists with hook configuration
2. ✅ `hook-log.sh` exists and is executable
3. ✅ `hook-log.txt` exists and contains timestamped entries
4. ✅ Writing files in workspace causes hook to fire
5. ✅ Log format: `[TIMESTAMP] File written: FILENAME`
6. ✅ Multiple file writes all logged

---

## What's Next

Once Step 1 is working, you'll move to Step 2: Sentinel File Schema Design (design before code).

The Hello World hook proves the mechanism works. Step 2 designs the real schema that the hook will validate.

---

## Files Created This Step

- `.claude/settings.json` (hook configuration, may already exist)
- `module-3/exercise-14/hook-log.sh` (executable hook script)
- `module-3/exercise-14/hook-log.txt` (auto-generated, populated by hook)

All three should be committed after successful testing.
