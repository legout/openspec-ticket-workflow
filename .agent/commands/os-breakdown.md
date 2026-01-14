---
name: os-breakdown
description: Break down a PRD/plan into OpenSpec proposals
role: planner
---

# /os-breakdown <source> [--with-tickets]

**Arguments:** $ARGUMENTS

Parse:
- `source`: Required. One of:
  - `@file.md` - A file reference
  - `@folder/` - A folder with plan documents
  - `https://...` - A URL to fetch
  - Inline text - A brief description
- `--with-tickets`: Auto-bootstrap tickets after creating proposals

## Steps

1. **Ingest source material**:
   - Read file, folder, URL, or inline text

2. **Deep analysis**:
   - Identify distinct features/components
   - Extract requirements and constraints
   - Capture context and rationale
   - Note technical considerations

3. **Plan proposal structure**:
   - Group into 3-10 feature-level proposals
   - Name with kebab-case IDs
   - Document relationships

4. **Create proposals**:
   For each identified feature:
   ```bash
   openspec init <id>
   ```
   Then create proposal.md and tasks.md

5. **Bootstrap tickets** (if `--with-tickets`):
   For each proposal:
   ```bash
   /tk-bootstrap <id> "<title>" --yes
   ```

## Output Format

```
## Breakdown Complete

### Proposals Created
| ID | Title | Tasks |
|----|-------|-------|
| <id> | <title> | N |

### Implementation Order
1. <id> - <rationale>
2. <id> - <rationale>

### Next Steps
- Review proposals in `openspec/changes/`
- Run `/tk-bootstrap <id> "<title>"` for each
- Or re-run with `--with-tickets` to auto-bootstrap
```

## Contract

**ALLOWED:** Reading files, `openspec init`, creating spec files, invoking `/tk-bootstrap`
**FORBIDDEN:** Implementing code, skipping proposals
