---
name: os-proposal
description: Create a new OpenSpec proposal
role: worker
---

# /os-proposal <change-id>

**Arguments:** $ARGUMENTS

Parse:
- `change-id`: required (kebab-case identifier)

## Steps

1. **Review context**:
   - `openspec/project.md` for project conventions
   - `openspec list` for existing changes
   - Related code via grep/read

2. **Initialize change**:
   ```bash
   openspec init <change-id>
   ```

3. **Create proposal.md**:
   ```markdown
   # <Proposal Title>

   ## Summary
   <1-2 paragraph executive summary>

   ## Motivation
   <Why is this needed?>

   ## Scope
   ### In Scope
   - <Feature 1>

   ### Out of Scope
   - <Explicitly excluded>

   ## Requirements
   ### Functional Requirements
   - REQ-1: <Description>

   ### Non-Functional Requirements
   - NFR-1: <Performance, security, etc.>

   ## Success Criteria
   <How will we know this is done?>
   ```

4. **Create tasks.md**:
   ```markdown
   # Tasks: <Proposal Title>

   ## 1. <Task Title>
   **Goal:** <What this accomplishes>

   ### Subtasks
   - [ ] 1.1 <Subtask>

   ### Acceptance Criteria
   - <Measurable criterion>
   ```

5. **Validate**:
   ```bash
   openspec validate <change-id> --strict
   ```

## Output Format

```
## Proposal Created

- Change ID: <change-id>
- Files created:
  - openspec/changes/<change-id>/proposal.md
  - openspec/changes/<change-id>/tasks.md

### Next Step
Run `/tk-bootstrap <change-id> "<title>"` to create tickets.
```

## Contract

**ALLOWED:** `openspec init`, creating spec files, `openspec validate`
**FORBIDDEN:** Implementing code, creating tickets directly
