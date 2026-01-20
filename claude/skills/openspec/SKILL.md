---
name: openspec
description: |
  Expertise in Spec-Driven Development (SDD) using OpenSpec. 
  Helps in drafting high-quality proposals, design docs, and managing the spec lifecycle.
  Keywords: proposal, spec, design, requirements, openspec
---

# OpenSpec Skill

You are an expert in Spec-Driven Development (SDD). Your goal is to ensure that every change starts with a clear, validated specification before any code is written.

## Core Expertise

- **Proposal Drafting:** Writing concise `proposal.md` files that capture the "what" and "why" of a change.
- **Detailed Design:** Creating `design.md` with enough technical detail (architecture, schema, API changes) to guide an agent or human.
- **Task Decomposition:** Breaking down a change into a logical sequence of tasks in `tasks.md`.
- **Validation:** Using `openspec validate` (and manual reviews) to ensure specs meet acceptance criteria.

## OpenSpec CLI Reference

| Command | Purpose |
|---------|---------|
| `openspec init <id>` | Initialize a new change |
| `openspec list` | List all active changes |
| `openspec show <id>` | Show change details |
| `openspec validate <id>` | Validate spec completeness |
| `openspec archive <id>` | Archive completed change |

## File Structure

```
openspec/
  project.md           # Project-level conventions
  specs/               # Current approved specs
  changes/
    <change-id>/
      proposal.md      # What and why
      design.md        # How (technical details)
      tasks.md         # Implementation tasks
      specs/           # Delta specs for this change
```

## Proposal Template

```markdown
# <Proposal Title>

## Summary
<1-2 paragraph executive summary>

## Motivation
<Why is this needed? What problem does it solve?>

## Scope
### In Scope
- <Feature 1>

### Out of Scope
- <Explicitly excluded items>

## Requirements
### Functional Requirements
- REQ-1: <Description>

### Non-Functional Requirements
- NFR-1: <Performance, security, etc.>

## Success Criteria
<How will we know this is done?>
```

## Operational Rules

1. **Specs before code** - Never implement without an approved spec
2. **Traceability** - Every change links to a proposal
3. **Archive on completion** - Use `openspec archive` when all tasks done

## /os-breakdown Workflow

Use this when a PRD/plan must be decomposed into multiple OpenSpec proposals.

### Inputs
- `@file.md`, `@folder/`, URL, or inline text
- Optional `--with-tickets` to auto-bootstrap after proposals

### Steps
1. **Ingest** the source (read file/folder/URL/inline text).
2. **Analyze** and identify discrete features (target 3–10 proposals).
3. **Name** proposals with verb-led kebab-case IDs.
4. **Plan output**: present the proposed set + dependency order.
5. **Create** each proposal:
   - `openspec init <id>`
   - Draft `proposal.md` (summary, motivation, scope, requirements, design considerations, risks, success)
   - Draft `tasks.md` (3–8 chunky tasks + acceptance criteria)
6. **Validate**: `openspec validate <id> --strict`.
7. **Optionally bootstrap**: `/tk-bootstrap <id> "<title>" --yes` if `--with-tickets`.

### Guardrails
- Do **not** implement code.
- Do **not** create tickets without proposals.
- Do **not** edit existing specs outside `openspec/changes/`.
