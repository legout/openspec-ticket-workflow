---
name: tk-bootstrap
description: Design and create tk epic + 3-8 chunky task tickets for an OpenSpec change
role: planner
---

# /tk-bootstrap <change-id> "<epic-title>" [--yes]

**Arguments:** $ARGUMENTS

Parse:
- `change-id`: first argument (required)
- `epic-title`: second argument (required, quoted string)
- `--yes`: optional flag to execute (without it, preview only)

## Execution Modes

### Preview Mode (default, no `--yes`)
- Analyze the OpenSpec change
- Design the ticket structure (3-8 chunky tickets)
- Output the exact `tk create` and `tk dep` commands that would run
- **DO NOT EXECUTE** any `tk create` or `tk dep` commands
- End with: "Re-run with `--yes` to execute these commands."

### Execute Mode (`--yes` flag present)
- Analyze the OpenSpec change
- Design the ticket structure
- **EXECUTE** all `tk create` and `tk dep` commands
- Show final state with `tk ready`

## Steps

1. Show change details: `openspec show <change-id>`
2. Understand proposal goals, scope, and acceptance criteria
3. Design 3-8 chunky tickets covering:
   - Database/model changes
   - API/backend logic
   - UI/frontend components
   - Tests
   - Documentation
4. Identify dependencies between tickets
5. Preview or execute based on mode

## Ticket Creation Pattern

```bash
# Create epic
tk create --type epic --external-ref "openspec:<change-id>" --title "<epic-title>"

# Create tasks
tk create --type task --parent <epic-id> --title "<task title>" --acceptance "<done criteria>"

# Add dependencies
tk dep <blocked-id> <blocker-id>
```

## Output Format

```
## Tickets Created

### Epic
- ID: <epic-id>
- Title: <epic-title>
- External ref: openspec:<change-id>

### Tasks
1. <task-id>: <title> (ready)
2. <task-id>: <title> (blocked by #1)
...

### Next Step
Run `/tk-queue` to see ready tickets, or `/tk-start <id>` to begin.
```

## Contract

**ALLOWED:** `openspec show`, `tk create`, `tk dep`, `tk query`, `tk show`
**FORBIDDEN:** `tk start`, `tk close`, editing code files, implementing features
