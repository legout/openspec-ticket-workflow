---
name: tk-refactor
description: Merge duplicate tickets and clean up backlog
role: planner
---

# /tk-refactor

Analyze the ticket backlog and suggest consolidations.

## Steps

1. **Get all tickets**: `tk query '.'`

2. **Identify duplicates**:
   - Similar titles
   - Overlapping file predictions
   - Same acceptance criteria

3. **Suggest merges**:
   - List candidate pairs
   - Explain rationale

4. **Clean up stale tickets**:
   - Identify old open tickets
   - Suggest closing or re-prioritizing

5. **Output recommendations** (do not execute without confirmation)

## Output Format

```
## Backlog Analysis

### Duplicate Candidates
1. <id-1> + <id-2>: <rationale>
2. <id-3> + <id-4>: <rationale>

### Stale Tickets (>30 days)
- <id>: <title> (created <date>)

### Suggested Actions
- Merge: <id-1> into <id-2>
- Close: <id> (superseded by <other-id>)

Confirm to execute? (y/n)
```

## Contract

**ALLOWED:** `tk query`, `tk show`, analysis
**FORBIDDEN:** Modifying tickets without confirmation
