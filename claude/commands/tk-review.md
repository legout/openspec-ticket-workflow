---
description: Review completed ticket for quality issues
argument-hint: <ticket-id>
allowed-tools: Bash(git:*), Bash(tk:*), Bash(openspec:*), Read, Grep
---

# /tk-review $1

Parse:
- `$1`: ticket-id (required)

## Current Context

Ticket details:
!`tk show $1`

Recent commits:
!`git log --oneline -5`

## Steps

1. **Get ticket and epic info**: `tk show <ticket-id>`
2. **Analyze changes**: `git diff`
3. **Read OpenSpec specs**: `openspec show <change-id>`
4. **Review categories** (adjust focus based on flag):
   - **spec-compliance**: Does implementation match requirements?
   - **tests**: Are acceptance criteria covered?
   - **security**: Obvious vulnerabilities?
   - **quality**: Code patterns, DRY, error handling?
   - **architecture**: (deep/ultimate) Design issues, coupling, maintainability?

5. **Create fix tickets** if needed:
   ```bash
   tk create "Fix: <issue>" --parent <epic-id> --priority 0 --tags review-fix
   tk link <new-id> <ticket-id>
   ```

6. **Add review note**:
   ```bash
   tk add-note <ticket-id> "<review summary>"
   ```

## Output Format

```
## Review (YYYY-MM-DD)

spec-compliance: ✅ passed / ⚠️ warning / ❌ error
tests: ...
security: ...
quality: ...

### Findings
- <issue with file:line reference>

### Fix Tickets Created
- <ticket-id>: <title>

### Summary
<overall assessment>
```

## Contract

**ALLOWED:** `git diff`, `tk add-note`, `tk create`, `tk link`, reading files
**FORBIDDEN:** Editing code files, implementing fixes

## Global-Style Flags (New 7-Scout System)

These flags select reviewers by **role** from `reviewer.scouts[]` config:

**Specialized reviewer flags:**
- `--spec-audit`: Run spec-audit role only (OpenSpec compliance)
- `--shallow-bugs`: Run shallow-bugs role only (obvious bugs, alias: `--fast`)
- `--history-context`: Run history-context role only (git blame/comments, alias: `--deep`)
- `--code-comments`: Run code-comments role only (TODO/FIXME compliance)
- `--intentional-check`: Run intentional-check role only (intentional vs bug)

**Flexible provider flags (multi-provider support):**
- `--fast-sanity`: Run fast-sanity role only (quick checks, any provider)
- `--second-opinion`: Run second-opinion role only (alt perspective, alias: `--seco`)

**Meta flags:**
- `--ultimate`: Run all 7 role-based scouts + **STRONG aggregator**
- `--standard`: Run default set (shallow-bugs, spec-audit)

**Precedence rules (highest to lowest):**
1. `--scouts ROLE,ROLE` (manual role selection, highest)
2. Specialized reviewer flags (`--spec-audit`, `--shallow-bugs`, etc.)
3. Flexible provider flags (`--fast-sanity`, `--second-opinion`)
4. `--ultimate` → all 7 scouts + STRONG aggregator
5. Adaptive complexity-based (default when no flags)

**Aliases:**
- `--fast` → alias for `--shallow-bugs`
- `--seco` → alias for `--second-opinion`

**Adaptive defaults:**
- Small (≤4 files, ≤200 lines): `shallow-bugs`, `spec-audit`
- Medium (≤12 files, ≤800 lines): + `history-context`
- Large / risky: All 7 scouts + STRONG aggregator
