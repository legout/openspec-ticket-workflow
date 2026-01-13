# Test Plan: File-Aware Dependency Management

This document outlines test scenarios for the file-aware dependency management feature introduced in the `add-file-aware-deps` change.

## Test Environment Setup

1. Ensure `tk` CLI is installed and functional
2. Initialize os-tk: `os-tk init` (or create `.os-tk/config.json` manually)
3. Create test tickets with file predictions

## Test 1: Flag Parsing for /tk-queue

### Test 1.1: Default behavior (no flags)
**Expected:** Recommend ONE ticket to start

**Steps:**
```bash
/tk-queue
```

**Verify:**
- Output shows exactly one ticket recommendation
- Ticket is in "ready" state
- No file overlap conflicts with in-progress tickets
- Suggests `/tk-start <ticket-id>` as next action

### Test 1.2: --next flag
**Expected:** Recommend ONE ticket to start

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Same behavior as default (no flags)
- Output shows exactly one ticket
- Clear explanation of why this ticket was chosen

### Test 1.3: --all flag
**Expected:** List ALL ready tickets

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Lists all ready tickets
- Shows file predictions for each ticket
- Reports any file overlaps detected
- Reports dependencies created (if any)
- Flags tickets missing file predictions

### Test 1.4: --change flag
**Expected:** Filter tickets to specific OpenSpec change

**Steps:**
```bash
/tk-queue --change my-feature
```

**Verify:**
- Shows only tickets belonging to the specified change
- Groups by: Ready, In Progress, Blocked
- Each ticket shows its status and dependencies

### Test 1.5: Combined flags
**Expected:** Apply both filters

**Steps:**
```bash
/tk-queue --all --change my-feature
```

**Verify:**
- Shows all tickets for the specified change
- Includes file overlap detection
- Shows file predictions for each ticket

## Test 2: File Overlap Detection

### Test 2.1: Detect overlapping files_modify
**Setup:** Create two tickets with overlapping files:
```yaml
# Ticket 1: ab-123
---
id: ab-123
status: open
files-modify:
  - src/api.ts
  - src/utils.ts
files-create: []
---

# Ticket 2: ab-456
---
id: ab-456
status: open
files-modify:
  - src/api.ts
  - src/auth.ts
files-create: []
---
```

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Detects overlap: both tickets modify `src/api.ts`
- Creates dependency: `tk dep <earlier-ticket> <later-ticket>`
- Output reports: "Created 1 dependency to prevent file conflicts"
- Earlier ticket (by creation timestamp) becomes the blocker

### Test 2.2: Detect overlapping files_create
**Setup:** Create two tickets with overlapping file creation:
```yaml
# Ticket 1: ab-789
---
id: ab-789
status: open
files-modify: []
files-create:
  - src/types/User.ts
---

# Ticket 2: ab-101
---
id: ab-101
status: open
files-modify: []
files-create:
  - src/types/User.ts
  - src/types/Order.ts
---
```

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Detects overlap: both create `src/types/User.ts`
- Creates dependency to serialize creation
- Output confirms dependency was added

### Test 2.3: Mixed overlap (modify + create)
**Setup:** Create tickets where one modifies and another creates the same file:
```yaml
# Ticket 1: ab-111
---
id: ab-111
status: open
files-modify:
  - src/config.ts
files-create: []

# Ticket 2: ab-222
---
id: ab-222
status: open
files-modify: []
files-create:
  - src/config.ts
---
```

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Detects overlap (file will be created by one, modified by another)
- Creates dependency: create should happen before modify
- Dependency direction respects file lifecycle

### Test 2.4: No overlap
**Setup:** Create tickets with disjoint file sets:
```yaml
# Ticket 1: ab-333
---
id: ab-333
status: open
files-modify:
  - src/api.ts
files-create: []

# Ticket 2: ab-444
---
id: ab-444
status: open
files-modify:
  - src/ui/components.ts
files-create: []
---
```

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- No dependencies created
- Both tickets can be started in parallel
- Output confirms no file conflicts detected

## Test 3: Auto-Dependency Injection

### Test 3.1: Dependency created via tk dep
**Setup:** Use Test 2.1 (overlapping files)

**Steps:**
```bash
/tk-queue --all
tk query '.id == "ab-456" | .deps'
```

**Verify:**
- Later ticket now has earlier ticket in its `deps` array
- Dependency reflects overlap detection
- `tk ready` no longer shows both tickets simultaneously

### Test 3.2: Existing dependency preserved
**Setup:** Create tickets with existing logical dependency + file overlap:
```bash
tk create --type task --title "Task A" --acceptance "Implement A"
tk create --type task --title "Task B" --acceptance "Implement B"
tk dep <task-b-id> <task-a-id>  # B depends on A
```
Then add file predictions with overlap.

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Original dependency is preserved
- No duplicate dependencies created
- `tk dep` respects existing relationships

## Test 4: Conflict Check with In-Progress Tickets (--next mode)

### Test 4.1: Skip conflicting ticket
**Setup:**
- Ticket A is `in_progress` and modifies `src/api.ts`
- Ticket B is `open` and also modifies `src/api.ts`

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Skips Ticket B with clear message
- Output includes: "⚠️ Skipping ab-456: modifies src/api.ts (already modified by in-progress ab-123)"
- Recommends a non-conflicting ticket instead

### Test 4.2: Recommend non-conflicting ticket
**Setup:**
- Ticket A is `in_progress` and modifies `src/api.ts`
- Ticket B is `open` and modifies `src/ui.ts` (no overlap)
- Ticket C is `open` and modifies `src/api.ts` (conflict)

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Recommends Ticket B (no conflict)
- Explains why Ticket C was skipped
- Output is clear and actionable

### Test 4.3: Multiple tickets in progress
**Setup:**
- Ticket A modifies `src/api.ts` (in_progress)
- Ticket B modifies `src/auth.ts` (in_progress)
- Ticket C modifies `src/ui.ts` (open, no conflict)
- Ticket D modifies `src/api.ts` (open, conflict with A)
- Ticket E modifies `src/auth.ts` (open, conflict with B)

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Only recommends Ticket C (no conflicts)
- Skips D and E with clear explanations
- Shows all conflict warnings

## Test 5: Missing File Predictions

### Test 5.1: Flag tickets without predictions
**Setup:** Create tickets without `files-modify` or `files-create`

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Output reports: "Note: N tickets lack file predictions"
- Lists which tickets are missing predictions
- Suggests running `tk show <id>` to add predictions

### Test 5.2: Tickets with predictions work normally
**Setup:** Mix tickets with and without file predictions

**Steps:**
```bash
/tk-queue --all
```

**Verify:**
- Tickets with predictions participate in overlap detection
- Tickets without predictions are flagged but still shown
- Clear distinction between predicted and unpredicted tickets

## Test 6: Worktree Awareness (if useWorktrees: true)

### Test 6.1: Detect active worktrees
**Setup:**
- Enable `useWorktrees: true` in config
- Start a ticket: `/tk-start ab-123`
- Worktree created at `.worktrees/ab-123/`

**Steps:**
```bash
/tk-queue
```

**Verify:**
- Marks `ab-123` as "in progress (worktree active)"
- Excludes it from ready recommendations
- Shows ticket as in-progress in output

### Test 6.2: Worktree + file overlap check
**Setup:**
- Worktree for ab-123 exists (modifies `src/api.ts`)
- ab-456 is open and also modifies `src/api.ts`

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Skips ab-456 due to file conflict with in-progress worktree
- Clear explanation of the conflict
- Recommends a ticket with no conflicts

## Test 7: Integration Tests

### Test 7.1: End-to-end workflow
**Steps:**
1. Create epic with `/tk-bootstrap`
2. Verify file predictions are added to each ticket
3. Run `/tk-queue --all` to see all tickets
4. Verify overlap detection creates dependencies
5. Run `/tk-queue --next` to get a safe recommendation
6. Start ticket with `/tk-start`
7. Run `/tk-queue --next` again (should skip conflicts)
8. Close ticket with `/tk-done`
9. Run `/tk-queue --next` (next ticket should be available)

**Verify:**
- Each command respects file-aware deps
- No merge conflicts occur during parallel work
- Workflow is smooth and predictable

### Test 7.2: Parallel execution with worktrees
**Setup:**
- Enable `useWorktrees: true`
- Create multiple tickets with no file overlaps

**Steps:**
```bash
/tk-queue --all
/tk-start <id1> <id2> <id3> --parallel 3
```

**Verify:**
- Three worktrees created simultaneously
- Each worktree on its own branch
- No file conflicts between tickets
- Implementation proceeds in parallel

## Test 8: Edge Cases

### Test 8.1: Empty file predictions
**Setup:** Ticket with empty arrays:
```yaml
---
files-modify: []
files-create: []
---
```

**Verify:**
- Ticket is treated as "no file impact"
- Can run in parallel with any ticket
- No overlap detection triggered

### Test 8.2: Large file lists
**Setup:** Ticket with 20+ files in predictions

**Verify:**
- Overlap detection handles large lists efficiently
- Output is readable and not truncated
- Dependencies created correctly for all overlaps

### Test 8.3: All tickets blocked by file deps
**Setup:**
- Ticket A (in_progress) modifies `src/api.ts`
- Ticket B, C, D all modify `src/api.ts`
- No other tickets available

**Steps:**
```bash
/tk-queue --next
```

**Verify:**
- Clear message: "No tickets available to start (all conflict with in-progress work)"
- Lists which tickets are blocked and why
- Suggests waiting for current work to complete

## Success Criteria

A test passes when:
- [ ] All flags parse correctly (`--next`, `--all`, `--change`)
- [ ] File overlaps are detected accurately
- [ ] Dependencies are created via `tk dep` command
- [ ] `--next` mode skips conflicting tickets
- [ ] Missing predictions are flagged appropriately
- [ ] Worktree awareness works (if enabled)
- [ ] No merge conflicts occur in parallel execution
- [ ] Documentation matches actual behavior
