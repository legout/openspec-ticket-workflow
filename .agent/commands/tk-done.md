---
name: tk-done
description: Close ticket, sync OpenSpec tasks, auto-archive, merge to main, and push
role: worker
---

# /tk-done <ticket-id> [change-id]

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: first argument (required)
- `change-id`: second argument (optional; auto-detected from epic's external_ref)

## Steps

1. **Identify OpenSpec change and epic ID**:
   - Get ticket: `tk show <ticket-id>` → extract `parent` as `epic-id`
   - Get epic: `tk show <epic-id>` → extract `external_ref` (format: `openspec:<change-id>`)

2. **Load config** from `.os-tk/config.json`

3. **Add note and close ticket**:
   ```bash
   tk add-note <ticket-id> "Implementation complete, closing via /tk-done"
   tk close <ticket-id>
   ```

4. **Sync OpenSpec tasks.md**:
   - Find matching checkbox in `openspec/changes/<change-id>/tasks.md`
   - Flip `[ ]` to `[x]`

5. **Check if all tasks complete**:
   ```bash
   tk query '.parent == "<epic-id>" and .status != "closed"'
   ```
   - If empty: `openspec archive <change-id> --yes`

6. **Commit changes**:
   - Rebase onto main (if worktrees)
   - Stage and commit: `git add -A && git commit -m "<ticket-id>: <title>"`

7. **Merge to main**:
   - `git checkout <mainBranch>`
   - `git merge --ff-only ticket/<ticket-id>`

8. **Push to remote** (if autoPush: true):
   ```bash
   git push origin <mainBranch>
   ```

9. **Cleanup** (worktree mode):
   ```bash
   git worktree remove .worktrees/<ticket-id>
   git branch -d ticket/<ticket-id>
   ```

## Output Format

```
## Ticket Closed

- Ticket: <ticket-id>
- OpenSpec synced: Yes/No
- OpenSpec archived: Yes/No (if all complete)
- Committed: <commit-hash>
- Merged to: <mainBranch>
- Pushed: Yes/No
```

## Contract

**DOES mutate state:**
- Closes ticket via `tk close`
- Edits `openspec/changes/<id>/tasks.md`
- May archive OpenSpec
- Creates git commits, merges, pushes

**Stop points:**
- Conflict resolution needed
- Missing change-id
- Push rejected
