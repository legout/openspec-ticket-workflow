# Change: Add Review Automation

## Why

After implementing a ticket and merging to main, there's no automated quality gate. Bugs, spec violations, and code quality issues slip through. Manual review is inconsistent and breaks the autonomous agent workflow (Ralph mode).

## What Changes

- **NEW**: `/tk-review <ticket-id>` command for post-implementation code review
- **NEW**: `/tk-run` command for autonomous start→done→review loop
- **NEW**: `reviewer` config section in `.os-tk/config.json`
- **NEW**: `os-tk-reviewer` agent role for review analysis
- **MODIFIED**: `/tk-done` gains optional `--review` flag for inline review

## Impact

- Affected specs: `os-tk-workflow`
- Affected files:
  - `.opencode/command/tk-review.md` (new)
  - `.opencode/command/tk-run.md` (new)
  - `.opencode/agent/os-tk-reviewer.md` (new)
  - `os-tk` (add reviewer config handling)
  - `AGENTS.md` (add new commands)

## Success Criteria

1. `/tk-review T-123` analyzes the merge commit, adds a review note to the ticket, and creates linked fix tickets if issues found
2. `/tk-run --all` autonomously processes the queue without user interaction until empty or max-cycles reached
3. Review tickets are linked (not blocked) to originals via `tk link`
4. Reviewer uses the planner model (reasoning-heavy) from config
