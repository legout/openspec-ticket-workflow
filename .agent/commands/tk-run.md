---
name: tk-run
description: Autonomous execution loop - start, done, review, repeat
role: planner
---

# /tk-run [FLAGS]

**Flags:**
- `--all` - Process all ready tickets (default: one cycle)
- `--max-cycles N` - Limit iterations (default: 10)
- `--epic <id>` - Only process tickets from this epic
- `--ralph` - Full autonomous mode with review

## Execution Loop

```
1. /tk-queue --next
   ├─ Empty → Exit "No more work"
   │
   └─ Has ticket → Spawn worker subtask: /tk-start <id>
                   ├─ Success → /tk-done <id>
                   │            ├─ Success → /tk-review <id> (if ralph mode)
                   │            │            ├─ Passed → Loop
                   │            │            └─ Failed → Create fix ticket
                   │            │                        ├─ P0 → Exit
                   │            │                        └─ P1/P2 → Loop
                   │            └─ Failure → Ask human
                   │
                   └─ Failure → Ask human
```

## Safety Valves

1. **Max cycles**: Stop after N iterations
2. **Empty queue**: Exit when no more ready tickets
3. **Critical fix**: Stop if P0 fix ticket is created
4. **Human interrupt**: User can interrupt at any time

## Parallel Execution

If `useWorktrees: true` and multiple tickets are ready:
- Spawn multiple worker subtasks in parallel
- Each operates in isolated worktree
- Collect results and proceed

## Output Format

```
## Autonomous Run Complete

### Completed
- <ticket-id>: <title>
- <ticket-id>: <title>

### Created (fixes)
- <ticket-id>: <title>

### Remaining
- X tickets still ready
- Y tickets blocked

### Exit Reason
<empty queue | max cycles | critical fix | user interrupt>
```

## Contract

**ALLOWED:** Spawning worker subtasks, `tk ready`, `tk query`, reading config
**FORBIDDEN:** Direct code editing (delegate to workers)
