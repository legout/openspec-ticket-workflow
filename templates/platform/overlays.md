# Platform Overlays Configuration

This file defines platform-specific deltas for template rendering.

## Platform Directory Mapping

| Platform | Agent Dir | Command/Prompt Dir | Skill Dir |
|----------|-----------|-------------------|-----------|
| opencode | agent/ | command/ | skill/ |
| claude   | agents/ | commands/ | skills/ |
| factory | droids/  | commands/ | skills/ |
| pi       | agents/ | prompts/  | skills/ |

## Frontmatter Conventions

### opencode
```yaml
---
agent: os-tk-worker
[ulw]
subtask: true
background: true
---
```

### claude/factory
```yaml
---
argument-hint: <ticket-id> [--parallel N]
allowed-tools: [bash, read, write, edit]
---
```

### pi
```yaml
---
description: Execute worker phase
# No special fields - minimal frontmatter
---
```

## Agent-Specific Overlays

### os-tk-planner
- **opencode**: `edit: deny`, `write: deny` (view-only)
- **pi/claude/factory**: `edit: allow`, `write: allow` (execution allowed)

### os-tk-worker
- **opencode**: `temperature: 0.2` (conservative)
- **pi/claude/factory**: `temperature: 0.75` (more creative)

## Command-Specific Overlays

### tk-done
- **opencode**: Full review gate + auto-rerun logic (300+ lines)
- **pi/claude/factory**: Simplified closure (review gate optional)

### tk-start
- **opencode**: Full parallelism logic + worktree details
- **pi**: Adds subagent pre-execution check

### tk-run
- **opencode**: Explicit cycle logic (start → review → done)
- **pi/claude/factory**: Skill stubs only

## Skill-Specific Overlays

### os-tk-workflow
- **opencode**: Gate-first pipeline (start → review → done)
- **pi/claude/factory**: Legacy order (may reference older pipelines)

### openspec
- **opencode/pi**: Operational logic only
- **claude/factory**: Includes CLI reference + templates

## Pre-Execution Checks

### pi platform
Add before command body:
```markdown
## Pre-execution Check

Verify the `subagent` extension is available:
```bash
pi ext list | grep subagent
```

If not available, install with:
```bash
pi ext install subagent
```
```

## Conditional Insertions

Use handlebars-style conditionals in templates:

```markdown
{{#opencode}}
opencode-specific content
{{/opencode}}

{{#pi}}
pi-specific content
{{/pi}}

{{#claude}}
claude-specific content
{{/claude}}

{{#factory}}
factory-specific content
{{/factory}}
```
