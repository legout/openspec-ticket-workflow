---
name: tk-queue
description: Show tk ready/blocked and suggest next work item(s) (view-only)
role: planner
---

# /tk-queue [FLAGS]

**Flags:**
- `--next` - Recommend ONE ticket to start (default)
- `--all` - List ALL ready tickets
- `--change <id>` - Filter tickets to a specific OpenSpec change

## Steps

1. **Gather queue status**:
   - Ready tickets: `tk ready`
   - Blocked tickets: `tk blocked`

2. **Check for active worktrees** (if `useWorktrees: true`):
   - List: `ls -d .worktrees/*/ 2>/dev/null`
   - Mark as "in progress (worktree active)"
   - Exclude from recommendations

3. **Filter by change** (if `--change` flag):
   - Find epic: `tk query '.external_ref == "openspec:<change-id>"'`
   - List tasks: `tk query '.parent == "<epic-id>"'`

4. **Output**:
   - For `--next`: Pick ONE ready ticket with rationale
   - For `--all`: List all ready tickets
   - For `--change`: Group by ready/in-progress/blocked

5. **Suggest next action**:
   > Run `/tk-start <ticket-id>` to begin implementation.

## Contract

**ALLOWED:** `tk ready`, `tk blocked`, `tk show`, `tk query`, reading config
**FORBIDDEN:** `tk start`, `tk close`, editing files, implementation

**STOP here. This command is view-only. Wait for user to run `/tk-start`.**
