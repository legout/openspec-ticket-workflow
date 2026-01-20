# Change: Refactor platform assets to template-based generation

## Why
Platform-specific agents, commands, and skills have drifted across opencode, pi, factory, and claude due to duplicated content. This makes it hard to keep workflow semantics consistent and increases maintenance cost. We want opencode to be the source of truth while enabling reliable, automated synchronization of platform-specific outputs.

## What Changes
- Introduce a template-based generation system for platform assets (agents, commands/prompts, skills).
- Treat **opencode content as the source of truth** for shared workflow semantics.
- Add platform-specific overlays/conditionals for frontmatter and execution checks (e.g., Pi subagent requirement).
- Update `os-tk init` and `os-tk apply` to render platform outputs from templates (and sync them deterministically).
- Update `os-tk sync` to fetch template sources and re-render platform outputs.
- Add validation/testing to ensure rendered outputs match expected platform layouts.

## Impact
- **Affected specs:** `specs/os-tk-workflow/spec.md`
- **Affected code:** `os-tk` CLI, template assets, platform directories (`opencode/`, `pi/`, `factory/`, `claude/`), docs
- **Behavioral changes:** `os-tk init`/`os-tk apply` will regenerate platform files from templates instead of copying diverged markdown.
