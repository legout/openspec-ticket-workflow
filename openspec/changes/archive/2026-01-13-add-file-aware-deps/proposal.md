# Change: Add File-Aware Dependency Management

## Why

When `tk ready` returns multiple tickets, they may appear parallelizable based on their logical dependencies, but could still touch the **same files**. This creates merge conflicts at rebase/merge time during `/tk-done`, even when using git worktrees for isolation.

The current dependency graph is purely conceptual (ticket A blocks ticket B) with no awareness of which files each ticket will modify. Worktrees provide implementation isolation but not conflict prevention.

## What Changes

- **Agent rename**: `os-tk-bootstrapper` → `os-tk-orchestrator` (expanded role)
- **File predictions**: Tickets gain `files-modify` and `files-create` YAML frontmatter fields
- **`/tk-bootstrap`**: Now predicts and stores file modifications for each ticket
- **`/tk-queue --all`**: Detects file overlaps, auto-generates missing predictions, adds hard deps via `tk dep`
- **`/tk-queue --next`**: Checks file conflicts with `in_progress` tickets before recommending
- **Argument style**: Changed from positional (`all`, `next`) to flags (`--all`, `--next`, `--change <id>`)
- **Config schema**: New `fileAwareDeps` section in `.os-tk/config.json`

## Impact

- Affected commands: `/tk-queue`, `/tk-bootstrap`
- Affected agents: `os-tk-bootstrapper` (renamed to `os-tk-orchestrator`), `os-tk-planner`
- Affected files:
  - `.opencode/agent/os-tk-bootstrapper.md` → `os-tk-orchestrator.md`
  - `.opencode/command/tk-queue.md`
  - `.opencode/command/tk-bootstrap.md`
  - `.opencode/skill/ticket/SKILL.md`
  - `os-tk` CLI (config schema, agent template)
- No changes to `tk` CLI itself (uses existing custom frontmatter support)
