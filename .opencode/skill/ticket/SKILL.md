---
name: ticket
description: Expertise in git-native task tracking using the `tk` CLI tool. Specialized in "chunky" task decomposition, dependency modeling, and spec-execution alignment.
---

# Ticket (tk) Skill

You are an expert in tracking and managing task execution using the `tk` CLI. You prioritize visibility, queue hygiene, and alignment with specifications.

## Core Expertise

- **Chunky Decomposition:** Instead of fine-grained checkboxes, you create 3–8 deliverable-sized task tickets per epic.
- **Dependency Modeling:** Using `tk dep` to encode real blockers, ensuring `tk ready` always points to actionable work.
- **Queue Management:** Regular use of `tk status`, `tk ready`, and `tk blocked` to maintain a clear path forward.
- **Syncing:** Ensuring that closing a `tk` ticket triggers an update to the source-of-truth specification (e.g., OpenSpec).

## Operational Rules

1. **External Ref:** Every epic MUST have `--external-ref "openspec:<change-id>"` if tracking an OpenSpec change.
2. **Acceptance Criteria:** Every ticket should have measurable "done" criteria using the `--acceptance` flag.
3. **Communication:** Use `tk add-note` to capture implementation details, test results, and blockers.
4. **Bootstrapping:** Use `/tk-bootstrap` to generate the initial execution graph from a spec.
5. **Starting Work:** Use `/tk-start` to begin a ticket — it shows context, acceptance criteria, and suggests an implementation plan.
6. **File Predictions:** Tickets may include `files-modify` and `files-create` arrays in frontmatter for parallel execution safety.

## Ticket Frontmatter Fields

### Standard Fields

- `id`: Unique ticket identifier (auto-generated)
- `status`: Ticket status (open, in_progress, closed)
- `deps`: Array of ticket IDs this ticket depends on
- `links`: Array of related ticket IDs (symmetric relationships)
- `created`: ISO timestamp of creation
- `type`: Ticket type (bug, feature, task, epic, chore)
- `priority`: Priority level 0-4 (0 = highest)
- `assignee`: Assigned user or agent
- `parent`: Parent epic ticket ID (for tasks)
- `external-ref`: External reference (e.g., "openspec:change-id")

### File-Aware Fields

- `files-modify`: Array of file paths that will be modified during implementation
- `files-create`: Array of file paths that will be created during implementation

**Example:**
```yaml
---
id: ab-123
status: open
files-modify:
  - src/api.ts
  - src/utils.ts
files-create:
  - src/types/User.ts
---
```

These fields enable:
- **Parallel safety:** Detect when multiple tickets modify the same files
- **Dependency inference:** Auto-generate dependencies based on file overlap
- **Conflict prevention:** `tk-queue` can warn about potential merge conflicts

**Note:** These fields are optional. Existing tickets without them remain valid.
