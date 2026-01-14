---
name: tk-start
description: Start one or more tk tickets and implement them
role: worker
---

# /tk-start <ticket-id> [ticket-id ...] [--parallel N]

**Arguments:** $ARGUMENTS

Parse arguments:
- All positional args are ticket IDs
- `--parallel N` sets concurrency (default: 3)

## Steps

1. **Load config** from `.os-tk/config.json`:
   - `useWorktrees` (boolean)
   - `worktreeDir` (default: ".worktrees")
   - `defaultParallel` (default: 3)

2. **Validate tickets are ready**: Run `tk ready` and filter requested IDs

3. **Check for active worktrees** (if enabled)

4. **Handle parallel execution policy**:
   - Single ticket: proceed directly
   - Multiple with worktrees: safe parallel allowed
   - Multiple without worktrees: requires `unsafe.allowParallel: true`

5. **Set up execution context**:
   - If worktrees: `git worktree add -b ticket/<id> .worktrees/<id>`
   - Otherwise: operate in current directory

6. **Execute implementation**:
   - Run `tk start <ticket-id>` to mark as in-progress
   - Show ticket details: `tk show <ticket-id>`
   - Implement deliverables and acceptance criteria
   - Run tests

7. **Completion**: Summarize and instruct to run `/tk-done <id>`

## Worker Contract

**ALLOWED:**
- Edit files, write code, refactor
- Run tests
- `tk show`, `tk start`

**FORBIDDEN:**
- `tk close` (use `/tk-done` instead)
- Archiving OpenSpec
- Merging branches or pushing
- Implementing multiple tickets in one flow

## Output Format

```
## Implementation Complete

### Files Modified
- path/to/file1.ts
- path/to/file2.ts

### Files Created
- path/to/new-file.ts

### Tests
- All tests passing (or list failures)

### Next Step
Run `/tk-done <ticket-id>` to close, commit, and merge.
```
