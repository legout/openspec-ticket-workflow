# Design: File-Aware Dependency Management

## Context

The os-tk workflow uses `tk` for task tracking with dependency modeling. Currently, dependencies are set based on logical/conceptual ordering ("auth before profile"). However, two tickets with no logical dependency may still modify the same files, causing merge conflicts when both are worked in parallel.

Git worktrees provide isolated working directories but do not prevent conflicts at merge time.

## Goals

- Prevent merge conflicts by serializing work on overlapping files
- Make parallel execution truly safe (not just isolated)
- Maintain simplicity of the `tk` CLI (no changes to it)
- Keep the agent layer responsible for file prediction and overlap detection

## Non-Goals

- Function/class-level granularity (file-level only)
- Tracking read-only file access (`files-read`)
- Validating predictions vs actual changes at `/tk-done` time
- Modifying the `tk` CLI source code

## Decisions

### 1. Storage Format: YAML Frontmatter

**Decision**: Store file predictions in ticket YAML frontmatter as `files-modify` and `files-create` arrays.

**Rationale**:
- `tk query` already parses and exposes custom frontmatter fields in JSON output
- Consistent with existing metadata style
- Easy to query: `tk query | jq -r '."files-modify"[]'`

**Alternatives considered**:
- HTML comments in body: Harder to parse, clutters display
- Separate metadata file: Adds complexity, out of sync risk

### 2. Overlap Resolution: Hard Dependencies

**Decision**: When file overlap is detected, add `tk dep <later> <earlier>` to serialize execution.

**Rationale**:
- Hard block ensures `tk ready` won't show conflicting tickets
- Deterministic ordering based on priority + ID
- User can override by removing dep if desired

**Alternatives considered**:
- Advisory warnings only: Users may ignore, defeats purpose
- Links instead of deps: Links are informational, don't affect `tk ready`

### 3. Prediction Generation: On-Demand in `/tk-queue --all`

**Decision**: If a ticket lacks file predictions, `/tk-queue --all` generates them by analyzing the ticket and codebase.

**Rationale**:
- Handles legacy tickets without predictions
- Single point of enforcement
- Agent can use full context (description, acceptance criteria, codebase)

**Alternatives considered**:
- Require at bootstrap time only: Breaks for existing tickets
- Skip unpredicted tickets: Reduces parallel safety

### 4. Agent Renaming

**Decision**: Rename `os-tk-bootstrapper` to `os-tk-orchestrator`.

**Rationale**:
- Agent now handles both bootstrapping (ticket creation) and queue management (file-aware deps)
- "Orchestrator" better reflects coordination role
- Avoids creating a third agent

### 5. Argument Style

**Decision**: Use `--flags` instead of positional args for `/tk-queue`.

**Rationale**:
- Consistent with other CLI conventions
- Clearer intent (`--all` vs `all`)
- Extensible for future flags

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Predictions may be wrong | Best-effort; over-predict rather than under-predict |
| Over-serialization (false positives) | User can remove deps manually if needed |
| Performance of file prediction | Cached analysis; only runs on first `/tk-queue --all` |
| Agent permission expansion | Well-documented contract; only edits ticket metadata |

## Migration Plan

1. Create new agent file `os-tk-orchestrator.md`
2. Update command files to reference new agent
3. Delete old `os-tk-bootstrapper.md`
4. Run `os-tk apply` to regenerate from config
5. Existing tickets without predictions: handled transparently by `/tk-queue --all`

## Open Questions

None remaining (all resolved in discussion).
