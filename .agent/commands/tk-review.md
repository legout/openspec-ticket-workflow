---
name: tk-review
description: Review completed ticket for quality issues
role: reviewer
---

# /tk-review <ticket-id>

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: required

## Steps

1. **Get ticket and epic info**:
   - `tk show <ticket-id>` → get parent epic
   - `tk show <epic-id>` → get OpenSpec change ID

2. **Analyze changes**:
   - Get merge commit: `git log --oneline -1`
   - Get diff: `git diff <parent-commit>..HEAD`

3. **Read OpenSpec specs**:
   - `openspec show <change-id>`
   - Read `openspec/changes/<change-id>/tasks.md`

4. **Review categories**:
   - **spec-compliance**: Does implementation match requirements?
   - **tests**: Are acceptance criteria covered by tests?
   - **security**: Obvious vulnerabilities (injection, auth, secrets)?
   - **quality**: Code patterns, DRY, error handling?

5. **Create fix tickets** (if issues found):
   ```bash
   tk create "Fix: <issue>" --parent <epic-id> --priority 0 --tags review-fix
   tk link <new-id> <original-id>
   ```

6. **Add review note**:
   ```bash
   tk add-note <ticket-id> "<review summary>"
   ```

## Output Format

```
## Review (YYYY-MM-DD)

spec-compliance: passed/warning/error
tests: passed/warning/error
security: passed/warning/error
quality: passed/warning/error

### Findings
- <issue with file:line reference>

### Fix Tickets Created
- <ticket-id>: <title>

### Summary
<overall assessment>
```

## Contract

**ALLOWED:** `git diff`, `git log`, `tk add-note`, `tk create`, `tk link`, reading files
**FORBIDDEN:** Editing code files, `tk start`, `tk close`, implementing fixes
