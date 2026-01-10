---
description: Create tk epic + 3–8 chunky task tickets for an OpenSpec change [ulw]
agent: os-tk-worker
permission:
  skill: allow
  bash: allow
---

# /tk-bootstrap <change-id> "<epic-title>"

**Arguments:** $ARGUMENTS

Parse:
- `change-id`: first argument (required)
- `epic-title`: second argument (required, quoted string)

---

## EXECUTION CONTRACT

This command **EXECUTES** ticket creation. It creates real tk tickets.

### ALLOWED
- `openspec list`, `openspec show <id>`, `openspec validate <id>`
- `tk create`, `tk dep`, `tk query`, `tk show`
- Summarize and recommend next steps

### FORBIDDEN
- `tk start`, `tk close`, `tk add-note` (those are `/tk-start` and `/tk-done`)
- Edit files or write code
- Archive OpenSpec
- Begin implementation

---

## Step 1: Analyze the OpenSpec change

Show the change details:
!`openspec show $1`

Use your **openspec** skill to understand:
- The proposal goals and scope
- The tasks.md deliverables (if exists)
- Acceptance criteria

## Step 2: Design the ticket structure

Plan 3–8 chunky tickets that cover:
- Database/model changes
- API/backend logic
- UI/frontend components
- Tests
- Documentation

Each ticket should be a meaningful deliverable, not a single checkbox.

## Step 3: Create the epic

Run:
```bash
tk create --type epic --external-ref "openspec:$1" --title "$2"
```

**Capture the epic ID** from the output (format: `Created ticket: <id>`).

## Step 4: Create task tickets

For each planned task (3–8 total), run:
```bash
tk create --type task --parent <epic-id> --title "<task title>" --acceptance "<measurable done criteria>"
```

Requirements:
- Use clear, actionable titles
- Include specific acceptance criteria (tests pass, behavior works, docs updated)
- Keep tickets chunky — deliverables, not individual checkboxes

## Step 5: Add dependencies (if needed)

Only add dependencies for real blockers:
```bash
tk dep <blocked-id> <blocker-id>
```

Example: If "Create API endpoints" must finish before "Build UI components", run:
```bash
tk dep <ui-task-id> <api-task-id>
```

## Step 6: Verify and report

Show the final state:
!`tk ready`

## Output

Summarize what was created:
- Epic: `<epic-id>` — "<epic-title>"
- Tasks created: `<count>`
- Dependencies added: `<count>`
- Ready to start: `<list of ready ticket IDs>`

Suggest next step:
> Run `/tk-queue` to see the full queue, or `/tk-start <ticket-id>` to begin implementation.

---

**STOP here. Do not begin implementation. The user will run `/tk-start` to begin work.**
