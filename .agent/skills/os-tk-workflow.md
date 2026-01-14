---
name: os-tk-workflow
description: Orchestrating the OpenSpec + ticket workflow. Decision trees for command selection, phase transitions, anti-patterns to avoid, and autonomous execution guidance.
---

# OpenSpec + Ticket Workflow Orchestration

This skill teaches you how to orchestrate the full os-tk workflow, from user intent to completed work.

## Workflow Overview

```
User Intent → Planning → Execution → Archive
     │            │           │          │
     │       /os-proposal  /tk-start   /tk-done
     │       /tk-bootstrap     │     (auto-archives)
     │            │            │
     └────────────┴────────────┴──────────────────┘
                        tk ready
```

## Decision Trees

### User Wants a New Feature

```
1. Does an OpenSpec proposal exist?
   ├─ NO  → /os-proposal <id>
   │        Then: /tk-bootstrap <id> "<title>"
   │        Then: /tk-queue to see ready work
   │
   └─ YES → Are there tickets?
            ├─ NO  → /tk-bootstrap <id> "<title>"
            └─ YES → /tk-queue or /tk-start <id>
```

### User Mentions a Bug

```
1. Is it a quick fix (< 1 hour)?
   ├─ YES → Create lightweight proposal or skip?
   │        Recommendation: Create minimal proposal for traceability
   │
   └─ NO  → Full proposal workflow
            /os-proposal fix-<bug-name>
```

### User Has a PRD/Plan Document

```
1. Is it a comprehensive plan with multiple features?
   ├─ YES → /os-breakdown @document.md --with-tickets
   │
   └─ NO  → Single feature? Use standard flow
            /os-proposal <id>
            /tk-bootstrap <id> "<title>"
```

## Command → Agent Mapping

| Command | Agent | Purpose |
|---------|-------|---------|
| `/os-change` | planner | View OpenSpec changes (read-only) |
| `/os-proposal` | worker | Create proposal files |
| `/os-breakdown` | planner | Analyze PRD, create multiple proposals |
| `/tk-bootstrap` | planner | Design + create tickets |
| `/tk-queue` | planner | View ready/blocked (read-only) |
| `/tk-start` | worker | Implement ticket |
| `/tk-done` | worker | Close, sync, merge, push |
| `/tk-review` | reviewer | Post-implementation review |
| `/tk-run` | planner | Autonomous loop (spawns workers) |
| `/tk-refactor` | planner | Clean up backlog |

## Anti-Patterns

### DO NOT: Skip the proposal
Always create at least a minimal `/os-proposal` for traceability.

### DO NOT: Create tickets without proposals
Tickets should link to specs via `external_ref`.

### DO NOT: Bypass /tk-done
Always use `/tk-done <id>` to complete work (syncs OpenSpec).

### DO NOT: Edit code during planning
Wait for explicit `/tk-start` command.

### DO NOT: Implement multiple tickets in one session
Complete one with `/tk-done`, then start another.

## Ralph Mode (Autonomous Execution)

- **Internal (`/tk-run --ralph`):** Subtask isolation
- **External (`./ralph.sh`):** Full process isolation

Safety valves:
- `--max-cycles N` limits iterations
- Exits when queue is empty
- Stops on P0 fix ticket creation

## Parallel Execution

### Safe Mode (useWorktrees: true)
Each ticket gets an isolated worktree + branch.

### Simple Mode (useWorktrees: false)
All work in main working tree. Only parallel if `unsafe.allowParallel: true`.

## Troubleshooting

### "No tickets are ready"
Run `tk blocked` to see what's waiting.

### "Change not found"
Run `openspec list` to see active changes.

### "Worktree already exists"
Run `git worktree remove .worktrees/<id>` then retry.
