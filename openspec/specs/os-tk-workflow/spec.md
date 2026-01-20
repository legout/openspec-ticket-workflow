# os-tk-workflow Specification

## Purpose
TBD - created by archiving change add-file-aware-deps. Update Purpose after archive.
## Requirements
### Requirement: File-Aware Dependency Management

The os-tk workflow SHALL track predicted file modifications for each ticket and automatically create dependencies between tickets that would modify the same files.

#### Scenario: File predictions stored in ticket frontmatter

- **GIVEN** a ticket is created via `/tk-bootstrap`
- **WHEN** the agent analyzes the ticket's deliverables
- **THEN** the ticket frontmatter SHALL contain `files-modify` and/or `files-create` arrays with predicted file paths

#### Scenario: Missing predictions generated on demand

- **GIVEN** a ticket exists without `files-modify` or `files-create` fields
- **WHEN** `/tk-queue --all` is executed
- **THEN** the agent SHALL analyze the ticket and codebase to generate predictions
- **AND** the ticket frontmatter SHALL be updated with the predictions

#### Scenario: Overlapping files create hard dependency

- **GIVEN** ticket-A predicts `files-modify: [src/api.ts]`
- **AND** ticket-B predicts `files-modify: [src/api.ts]`
- **AND** both tickets are in `tk ready` output
- **WHEN** `/tk-queue --all` is executed
- **THEN** `tk dep ticket-B ticket-A` SHALL be executed (assuming A has higher priority or earlier ID)
- **AND** ticket-B SHALL no longer appear in `tk ready`

#### Scenario: In-progress conflict check for --next

- **GIVEN** ticket-X is `in_progress` with `files-modify: [src/utils.ts]`
- **AND** ticket-Y is ready with `files-modify: [src/utils.ts]`
- **WHEN** `/tk-queue --next` is executed
- **THEN** ticket-Y SHALL NOT be recommended
- **AND** the output SHALL indicate ticket-Y conflicts with ticket-X

### Requirement: Consistent Flag-Based Arguments

The `/tk-queue` command SHALL use flag-style arguments for mode selection.

#### Scenario: Default behavior with no flags

- **WHEN** `/tk-queue` is executed with no arguments
- **THEN** the behavior SHALL be equivalent to `/tk-queue --next`

#### Scenario: Explicit --next flag

- **WHEN** `/tk-queue --next` is executed
- **THEN** exactly ONE ready ticket SHALL be recommended

#### Scenario: --all flag lists all ready tickets

- **WHEN** `/tk-queue --all` is executed
- **THEN** ALL ready tickets SHALL be listed after overlap resolution

#### Scenario: --change flag filters by OpenSpec change

- **WHEN** `/tk-queue --change <change-id>` is executed
- **THEN** only tickets linked to that change SHALL be shown

### Requirement: Orchestrator Agent Role

The `os-tk-orchestrator` agent SHALL handle both ticket bootstrapping and queue management with file-aware dependencies.

#### Scenario: Agent permissions allow ticket metadata editing

- **GIVEN** the `os-tk-orchestrator` agent is invoked
- **WHEN** executing `/tk-queue --all` or `/tk-bootstrap`
- **THEN** the agent SHALL have permission to edit ticket frontmatter
- **AND** the agent SHALL have permission to run `tk dep`

#### Scenario: Agent forbidden from implementation

- **GIVEN** the `os-tk-orchestrator` agent is invoked
- **WHEN** any command is executed
- **THEN** the agent SHALL NOT edit code files (*.py, *.ts, *.js, etc.)
- **AND** the agent SHALL NOT run `tk start`, `tk close`, or begin implementation

### Requirement: Post-Implementation Code Review

The os-tk workflow SHALL provide automated code review for open tickets via `/tk-review`, using deterministic diff inputs and a lead reviewer that produces a consolidated PASS/FAIL summary.

#### Scenario: Review requires ticket to be open
- **GIVEN** ticket T-123 is closed
- **WHEN** `/tk-review T-123` is executed
- **THEN** the command SHALL refuse
- **AND** it SHALL instruct the user to reopen the ticket

#### Scenario: Review uses merge-base diff for open tickets
- **GIVEN** ticket T-123 is open on a worktree branch
- **WHEN** `/tk-review T-123` is executed
- **THEN** the reviewer SHALL analyze the git diff from merge-base to `HEAD`
- **AND** record base/head/merge-base metadata

#### Scenario: Review writes consolidated summary note
- **GIVEN** `/tk-review T-123` completes analysis
- **WHEN** the lead reviewer merges findings
- **THEN** a single consolidated review note SHALL be added
- **AND** the note SHALL include PASS/FAIL plus diff hash metadata

#### Scenario: Followups created only when policy allows
- **GIVEN** the review policy is `gate-with-followups`
- **WHEN** the review result is PASS with warnings above threshold
- **THEN** followup tickets SHALL be created and linked
- **AND** no followups SHALL be created for failed reviews

#### Scenario: Review respects skip tags
- **GIVEN** ticket T-123 has a tag listed in `reviewer.skipTags`
- **WHEN** `/tk-review T-123` is executed
- **THEN** the review SHALL be skipped
- **AND** the note SHALL indicate `SKIPPED` with metadata

### Requirement: Autonomous Execution Loop

The os-tk workflow SHALL provide autonomous queue processing via `/tk-run` with a review-before-done sequence.

#### Scenario: Run processes queue with gate-first order
- **GIVEN** the ready queue contains tickets [T-1, T-2]
- **WHEN** `/tk-run --ralph` is executed
- **THEN** for each ticket in queue order:
  - `/tk-start <id>` SHALL be called
  - `/tk-review <id>` SHALL be called
  - `/tk-done <id>` SHALL be called

#### Scenario: Run stops on failed review in gate mode
- **GIVEN** the review policy is `gate`
- **WHEN** `/tk-review <id>` returns FAIL
- **THEN** the `/tk-run` loop SHALL stop immediately
- **AND** the ticket SHALL remain open

#### Scenario: Run exits on critical fix ticket
- **GIVEN** `/tk-review` creates a P0 (critical) fix ticket
- **WHEN** the review step completes
- **THEN** the `/tk-run` loop SHALL exit
- **AND** output SHALL indicate a critical issue

### Requirement: Reviewer Agent Role

Reviewer agents SHALL analyze code changes without modifying implementation, using role reviewers for findings and a lead reviewer to consolidate results.

#### Scenario: Role reviewers are read-only
- **GIVEN** a role reviewer is invoked
- **WHEN** analyzing the implementation
- **THEN** the role reviewer SHALL read specs and diffs
- **AND** it SHALL NOT edit code files or create tickets

#### Scenario: Lead reviewer consolidates and writes note
- **GIVEN** role reviewers have produced findings
- **WHEN** the lead reviewer runs
- **THEN** it SHALL dedupe and merge findings deterministically
- **AND** it SHALL write the consolidated review note

#### Scenario: Lead reviewer may create followup tickets
- **GIVEN** the policy allows followups and thresholds are met
- **WHEN** the lead reviewer finalizes results
- **THEN** it SHALL create and link followup tickets as configured

### Requirement: Reviewer Configuration

The `.os-tk/config.json` SHALL support a `reviewer` configuration that defines roles, policy, thresholds, and skip tags.

#### Scenario: Config includes role definitions
- **GIVEN** `os-tk init` is run on a new project
- **WHEN** `config.json` is created
- **THEN** it SHALL include `reviewer.roles` with role entries and models

#### Scenario: Policy and thresholds control blocking
- **GIVEN** a reviewer config with `policy`, `blockSeverities`, and `blockMinConfidence`
- **WHEN** the lead reviewer evaluates findings
- **THEN** PASS/FAIL SHALL be determined by those settings

#### Scenario: Legacy scouts auto-migrate with warning
- **GIVEN** a legacy config with `reviewer.scouts`
- **WHEN** `os-tk apply` is executed
- **THEN** roles SHALL be derived from scouts in-memory
- **AND** a warning SHALL instruct users to migrate

### Requirement: Review Gate on /tk-done

The `/tk-done` command SHALL enforce a passing, up-to-date review before closing, merging, or pushing a ticket.

#### Scenario: PASS review required for current HEAD and diff hash
- **GIVEN** a ticket is ready to close
- **WHEN** `/tk-done <id>` is executed
- **THEN** the latest review note SHALL be `PASS`
- **AND** the note SHALL match the current `HEAD` and diff hash

#### Scenario: Stale or missing review blocks closure
- **GIVEN** no review exists for the current `HEAD` or diff hash
- **WHEN** `/tk-done <id>` is executed
- **THEN** the command SHALL refuse to close
- **AND** it SHALL instruct the user to run `/tk-review <id>`

#### Scenario: Auto-rerun guardrails when enabled
- **GIVEN** `reviewer.autoRerunOnDone` is enabled
- **WHEN** `/tk-done <id>` detects a missing or stale review
- **THEN** it MAY attempt a review rerun only if the working tree is clean, the base ref is deterministic, and no secrets are detected in the diff
- **AND** it SHALL refuse if any guardrail fails

