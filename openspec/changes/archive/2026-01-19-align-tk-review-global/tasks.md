# Tasks

## Phase 1: Core OpenCode Implementation (opencode/)

- [x] **T-1**: Update `/tk-review` command contract with global flags
  - File: `opencode/command/tk-review.md`
  - Add flag documentation, precedence rules, role mapping
  - Document `--ultimate` ⇒ STRONG aggregator behavior

- [x] **T-2**: Update `/tk-review-fast` and `/tk-review-strong` for review packet standardization
  - Files: `opencode/command/tk-review-fast.md`, `opencode/command/tk-review-strong.md`
  - Add "Review Packet" assembly (tk show, diff, stats, OpenSpec context)
  - Ensure scouts receive consistent context

- [x] **T-3**: Update router agent generator for flag semantics
  - File: `os-tk` script → `rebuild_review_router_from_template()`
  - Embed flag parsing, precedence, role-based selection
  - Keep router read-only contract

- [x] **T-4**: Update scout agent generator for read-only permissions
  - File: `os-tk` script → `rebuild_scout_from_template()`
  - Remove `tk *` permissions
  - Allow `git *`, read tools only

- [x] **T-5**: Update aggregator permissions (exclusive writer enforcement)
  - File: `os-tk` script → `rebuild_aggregator_from_template()`
  - Allow `tk show`, `tk add-note`, `tk create`, `tk link`
  - Disallow `tk close`, `tk start`

- [x] **T-6**: Add config validation for one-scout-per-role
  - File: `os-tk` script → `rebuild_reviewer_scouts()` or new validation function
  - Check for duplicate roles in `reviewer.scouts[]`
  - Error with clear message if duplicates found

## Phase 2: Cross-Platform Consistency (claude/, factory/, pi/)

- [x] **T-7**: Update Claude `/tk-review` command
  - File: `claude/commands/tk-review.md`
  - Add global flag interface
  - Document single-agent fallback behavior

- [x] **T-8**: Update Factory `/tk-review` command
  - File: `factory/commands/tk-review.md`
  - Add global flag interface
  - Document single-agent fallback behavior

- [x] **T-9**: Update Pi `/tk-review` prompt
  - File: `pi/prompts/tk-review.md`
  - Add global flag interface
  - Keep multi-scout via Pi subagent extension

## Phase 3: Documentation & Testing

- [x] **T-10**: Update AGENTS.md if needed
  - Document global-style flags in workflow section
  - Clarify role-based scout selection

- [x] **T-11**: Manual validation testing
  - Test each flag variant with `opencode/`
  - Test cross-platform flag recognition
  - Verify config validation (duplicate roles)
  - Verify `--ultimate` forces STRONG aggregator
