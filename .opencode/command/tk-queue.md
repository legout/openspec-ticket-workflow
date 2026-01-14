---
description: Show tk ready/blocked and suggest next work item(s) (view-only, does NOT start work) [ulw]
agent: os-tk-planner
---

# /tk-queue [FLAGS]

**Flags:**
- `--next` - Recommend ONE ticket to start (default if no flags provided)
- `--all` - List ALL ready tickets
- `--change <id>` - Filter tickets to a specific OpenSpec change

**Examples:**
- `/tk-queue` or `/tk-queue --next` - Show one recommended ticket
- `/tk-queue --all` - List all ready tickets
- `/tk-queue --change my-feature` - Filter tickets for a specific change

## Mode Detection

Parse flags from `$ARGUMENTS`:
- If no flags or `--next` present: Recommend ONE ticket to start
- If `--all` present: List ALL ready tickets
- If `--change <id>` present: Filter to that OpenSpec change
- Flags can be combined: `/tk-queue --all --change my-feature`

## Step 1: Gather queue status

Ready tickets:
!`tk ready`

Blocked tickets:
!`tk blocked`

## Step 2: Check for active worktrees (if enabled)

Read `.os-tk/config.json` for `useWorktrees`.

If `useWorktrees: true`:
- List active worktrees: `ls -d .worktrees/*/ 2>/dev/null`
- Mark those ticket IDs as "in progress (worktree active)"
- Exclude them from "ready to start" recommendations

## Step 2.5: File-overlap detection and auto-deps (for --all and --next)

Get all tickets with file predictions:
!`tk query 'select(.files_modify != null or .files_create != null) | {id, files_modify, files_create, status, parent}'`

For `--all` mode:
- Detect file overlaps: Check if multiple tickets share files in `files_modify` or `files_create`
- For each overlap, create dependency using: `tk dep <earlier-ticket> <later-ticket>`
  - Earlier ticket = older created timestamp or existing dependency relationship
  - Later ticket = newer created timestamp or the one being blocked
- Summarize dependencies created: "Created 3 dependencies to prevent file conflicts"
- Flag tickets missing predictions: "Note: 2 tickets lack file predictions (run `tk show <id>` to add)"

For `--next` mode:
- Check if recommended ticket's files overlap with in-progress tickets
- If conflict found, skip and recommend another ticket
- Explain the conflict clearly: "⚠️ Skipping ab-123: modifies src/api.ts (already modified by in-progress ab-456)"
- Continue searching until a non-conflicting ticket is found

## Step 2.6: Generate missing file predictions (optional, for --all)

If `--all` flag includes `--generate-predictions`:
- Find tickets without `files_modify` or `files_create` fields
- For each ticket, analyze title/description to predict file changes
- Ask user to confirm predictions before adding: "Predicted for ab-789: files_modify=[src/api.ts], files_create=[src/types/User.ts]. Add? (y/n)"
- If confirmed, add predictions via `tk add-note` or direct file edit

## Step 3: Filter by change (if --change flag provided)

If `--change <id>` flag is present:
1. Find the epic: `tk query '.external_ref == "openspec:<change-id>"'`
2. List tasks under that epic: `tk query '.parent == "<epic-id>"'`
3. Show only those tickets in ready/blocked output

## Step 4: Output

**For `--next` or no flags:**
Pick ONE ready ticket and show:
- Ticket ID
- Title & brief summary
- File predictions (if available)
- Why it's a good choice (e.g., no dependencies, no file conflicts, unblocks others)
- Conflict explanation (if skipping tickets due to file overlaps with in-progress work)

**For `--all`:**
List ALL ready tickets with:
- Ticket ID
- Title
- File predictions (if available)
- Overlap warnings (if conflicts detected)
- Brief status note

After listing, show:
- Dependencies created: "Created 3 dependencies to prevent file conflicts"
- Tickets missing predictions: "Note: 2 tickets lack file predictions"

**For `--change <id>`:**
Show tickets grouped:
- Ready (can start now)
- In progress (worktree active or `tk status == in_progress`)
- Blocked (and what's blocking them)

**For combined flags (e.g., `--all --change <id>`):**
Apply both filters - show all tickets for the specified change

## Step 5: Suggest next action

**For `--next` or no flags:**
> Would you like me to start this ticket? Run `/tk-start <ticket-id>`

**For `--all`:**
> To start one ticket: `/tk-start <ticket-id>`
> To start multiple in parallel: `/tk-start <id1> <id2> <id3>`

**For `--change <id>`:**
> Ready tickets for this change can be started with `/tk-start <id>`

---

## COMMAND CONTRACT

### ALLOWED
- `tk ready`, `tk blocked`, `tk show <id>`, `tk query <filter>`
- `tk dep <id1> <id2>` - Create dependencies to resolve file overlaps (for `--all` mode)
- `openspec list`, `openspec show <id>`
- Reading `.os-tk/config.json`
- Listing `.worktrees/` directory contents
- Reading ticket files to check for missing file predictions
- Summarize, analyze, and recommend

### FORBIDDEN
- `tk start`, `tk close`, `tk add-note`, or any other mutating `tk` command (except `tk dep`)
- Edit files, write code, run tests (unless explicitly adding file predictions with user confirmation)
- Create implementation plans or suggest code changes
- Spawn worker subtasks

### SELF-CHECK (before responding)

Confirm you did NOT:
- [ ] Suggest any implementation steps or code
- [ ] Propose running `tk start`, `tk add-note`, or `tk close`
- [ ] Edit or propose edits to any files
- [ ] Create an implementation plan

If you violated any of the above, remove it and remind the user to run `/tk-start`.

---

**STOP here. This command is view-only. Wait for user to run `/tk-start`.**
