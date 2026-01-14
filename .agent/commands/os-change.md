---
name: os-change
description: View OpenSpec change status (view-only)
role: planner
---

# /os-change [change-id]

**Arguments:** $ARGUMENTS

Parse:
- `change-id`: optional (if omitted, list all changes)

## Steps

### If no change-id provided:

1. List all active changes:
   ```bash
   openspec list
   ```

2. Show summary table:
   ```
   | ID | Title | Status | Tasks |
   |----|-------|--------|-------|
   | <id> | <title> | proposal/in-progress | 3/5 |
   ```

### If change-id provided:

1. Show change details:
   ```bash
   openspec show <change-id>
   ```

2. Show linked tickets:
   ```bash
   tk query '.external_ref == "openspec:<change-id>"'
   ```

3. Summarize progress:
   - Tasks completed vs total
   - Tickets: ready/in-progress/blocked/closed

## Output Format

```
## Change: <change-id>

### Proposal
<summary from proposal.md>

### Progress
- Tasks: 3/5 complete
- Tickets: 2 ready, 1 in-progress, 2 blocked

### Tickets
- <id>: <title> (status)
- <id>: <title> (status)

### Next Step
Run `/tk-queue` to see ready tickets.
```

## Contract

**ALLOWED:** `openspec list`, `openspec show`, `tk query`, reading files
**FORBIDDEN:** Modifying anything - this is view-only

**STOP here. This command is view-only.**
