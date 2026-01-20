# Project Context

## Purpose

os-tk (OpenSpec + Ticket) is a lightweight, agent-friendly development workflow template that combines:
- **OpenSpec** for spec-driven changes (proposal -> apply -> archive)
- **Ticket (`tk`)** for git-backed task tracking (ready/blocked queues + dependencies)
- **OpenCode** slash commands for multi-agent orchestration

The goal is to provide AI coding agents with consistent operating rules and workflows for planning, bootstrapping, and executing development tasks.

## Tech Stack

- Bash (os-tk CLI, ~700 lines)
- Markdown (agent definitions, command specs, skills)
- YAML frontmatter (ticket metadata)
- JSON (configuration in `.os-tk/config.json`)
- OpenCode plugin SDK (@opencode-ai/plugin)

## Project Conventions

### Code Style

- Shell scripts use `set -euo pipefail`
- Functions prefixed with `cmd_` for CLI commands
- Configuration accessed via `get_config_value()` helper
- Portable commands for macOS/Linux compatibility

### Architecture Patterns

- **Three-agent model**: Planner (view-only), Orchestrator (tickets + deps), Worker (implementation)
- **Command contracts**: Each slash command has explicit ALLOWED/FORBIDDEN actions
- **Skill-based expertise**: Agents load skills for domain knowledge (openspec, ticket)
- **Config-driven**: Models, permissions, and behavior controlled via `.os-tk/config.json`

### Ticket Conventions

- **Chunky decomposition**: 3-8 deliverable-sized tickets per epic (not fine-grained checkboxes)
- **External refs**: Epics link to OpenSpec via `--external-ref "openspec:<change-id>"`
- **File predictions**: Tickets include `files-modify` and `files-create` frontmatter for parallel safety
- **Dependency-first**: Use `tk dep` for real blockers; `tk ready` shows actionable work

### Git Workflow

- **Worktrees for parallel work**: Each ticket gets isolated worktree in `.worktrees/<ticket-id>/`
- **Branch naming**: `ticket/<ticket-id>` for feature branches
- **Merge strategy**: Rebase onto main before merge via `/tk-done`
- **Auto-push**: Configurable via `autoPush` in config

## Domain Context

### Workflow Stages

1. **Planning**: `/plan`, `/openspec-proposal` - Create specs before code
2. **Bootstrapping**: `/tk-bootstrap` - Create epic + task tickets from spec
3. **Queue management**: `/tk-queue` - View ready tickets, resolve file overlaps
4. **Execution**: `/tk-start` - Implement ticket in isolated context
5. **Completion**: `/tk-done` - Close, sync, merge, push, archive

### Agent Roles

| Agent | Role | Permissions |
|-------|------|-------------|
| `os-tk-planner` | View-only analysis, queue inspection | No edits, no writes |
| `os-tk-orchestrator` | Ticket creation, file-aware deps | Edit tickets only |
| `os-tk-worker` | Code implementation | Full edit/write |

## Important Constraints

- **Never edit code in planner/orchestrator context** - Only worker implements
- **Always use `/tk-done` to close work** - Ensures sync, archive, merge, push
- **File predictions are best-effort** - Over-predict rather than under-predict
- **Worktrees isolate but don't prevent merge conflicts** - File-aware deps serialize overlapping work

## External Dependencies

- **OpenSpec CLI** (`openspec`): Spec-driven development tooling
- **Ticket CLI** (`tk`): Git-native task tracking with dependencies
- **jq**: JSON processing for config and queries
- **git**: Version control with worktree support
- **OpenCode**: AI coding assistant with plugin support
