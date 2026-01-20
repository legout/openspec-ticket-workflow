# Design: Review Automation

## Context

The os-tk workflow currently ends at `/tk-done` (commit, merge, push). There's no automated feedback loop to catch issues before moving to the next ticket. This design adds:

1. **Post-implementation review** via `/tk-review`
2. **Autonomous execution loop** via `/tk-run`

## Goals

- Enable fully autonomous agent operation (Ralph mode)
- Catch spec violations, missing tests, and code quality issues
- Create actionable fix tickets linked to originals
- Use reasoning models (OPUS 4.5, GPT-5.2) for review analysis

## Non-Goals

- Replace human code review for critical changes
- Implement PR-based review workflows (this is post-merge)
- Build a general-purpose linting system

## Decisions

### D1: Per-Ticket Review (not per-Epic)

**Decision**: Review each ticket immediately after `/tk-done`.

**Rationale**:
- Clear traceability: fix ticket links to specific original
- Immediate feedback: issues caught before next ticket starts
- Simpler implementation: single commit diff vs merged epic diff

**Alternative considered**: Per-epic review batches all work, but attribution of issues is ambiguous.

### D2: `tk link` for Fix Tickets (not `tk dep`)

**Decision**: Use `tk link` (non-blocking symmetric association) for review→original relationships.

**Rationale**:
- Fix tickets should appear in `tk ready` immediately
- Original ticket is already closed; deps would be meaningless
- Links provide traceability without blocking queue flow

**Alternative considered**: `tk dep` would block subsequent work until fix is done, but that's too strict for minor issues.

### D3: Review Output via `tk add-note`

**Decision**: Always add review summary to the original ticket.

**Format**:
```markdown
## Review (2026-01-13)
✅ Spec compliance: passed
⚠️ Missing edge case test for null input
❌ Security: SQL injection risk in query builder

Created: T-456 (linked)
```

**Rationale**: Audit trail stays with the ticket, visible in `tk show`.

### D4: Reviewer Agent Role

**Decision**: Create `os-tk-reviewer` agent with planner-level model.

**Permissions**:
- Read: All files, specs, ticket data
- Write: `tk add-note`, `tk create`, `tk link`
- Forbidden: Code edits, `tk start`, `tk close`

**Model**: Uses `config.reviewer.model` (defaults to `config.planner.model`).

### D5: `/tk-run` Autonomous Loop

**Decision**: Single command that loops: queue → start → done → review → repeat.

**Safety valves**:
- `--max-cycles N`: Stop after N iterations (default: 10)
- Exit on empty queue
- Exit on review creating critical-priority fix tickets

## Config Schema Extension

```json
{
  "reviewer": {
    "model": "anthropic/claude-opus-4-5-20250514",
    "autoTrigger": "manual",
    "categories": ["spec-compliance", "tests", "security", "quality"],
    "createTicketsFor": ["error", "warning"],
    "skipTags": ["no-review", "wip"]
  }
}
```

| Field | Description |
|-------|-------------|
| `model` | Model ID for reviewer (defaults to planner.model) |
| `autoTrigger` | `manual` (explicit /tk-review) or `on-done` (auto after /tk-done) |
| `categories` | Which review checks to run |
| `createTicketsFor` | Severity threshold for creating fix tickets |
| `skipTags` | Tickets with these tags skip review |

## Review Categories

| Category | What it checks |
|----------|---------------|
| `spec-compliance` | Does implementation match OpenSpec requirements? |
| `tests` | Are acceptance criteria covered by tests? |
| `security` | Obvious vulnerabilities (injection, auth, secrets) |
| `quality` | Code patterns, DRY violations, error handling |

## `/tk-run` Flow

```
/tk-run [<id...>|--all] [--parallel N] [--max-cycles 10]

1. Load config
2. cycles = 0
3. LOOP:
   a. If cycles >= max-cycles: EXIT "Max cycles reached"
   b. Run /tk-queue --next
   c. If no ready tickets: EXIT "Queue empty"
   d. Run /tk-start <ticket-id>
   e. Run /tk-done <ticket-id>
   f. If reviewer.autoTrigger == "on-done":
      - Run /tk-review <ticket-id>
   g. cycles++
   h. GOTO 3
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Review creates infinite fix loop | `--max-cycles` limit; exit on critical fix tickets |
| Reviewer model costs | Use cheaper model for routine reviews; expensive for complex |
| False positives create noise | `createTicketsFor: ["error"]` ignores warnings by default |

## Open Questions

1. Should `/tk-run` pause for human approval before creating fix tickets?
2. Should review check only the diff or the full affected files?
3. How to handle review of changes that span multiple tickets in an epic?
