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

The os-tk workflow SHALL provide automated code review after ticket implementation via the `/tk-review` command.

#### Scenario: Review analyzes merge commit

- **GIVEN** ticket T-123 has been completed via `/tk-done`
- **WHEN** `/tk-review T-123` is executed
- **THEN** the reviewer agent SHALL analyze the git diff of T-123's merge commit
- **AND** compare changes against OpenSpec specs and acceptance criteria

#### Scenario: Review adds note to original ticket

- **GIVEN** `/tk-review T-123` completes analysis
- **WHEN** the review has findings (pass or fail)
- **THEN** `tk add-note T-123` SHALL be called with a formatted review summary
- **AND** the note SHALL include category results (✅/⚠️/❌) and any created fix ticket IDs

#### Scenario: Review creates linked fix tickets

- **GIVEN** `/tk-review T-123` finds issues meeting severity threshold
- **WHEN** `reviewer.requireSeverity` includes the issue severity
- **THEN** a new ticket SHALL be created via `tk create "Fix: <issue summary>"`
- **AND** `tk link <new-id> T-123` SHALL be called (non-blocking association)
- **AND** the fix ticket SHALL inherit the same parent epic as T-123

#### Scenario: Review respects skip tags

- **GIVEN** ticket T-123 has a tag listed in `reviewer.skipTags`
- **WHEN** `/tk-review T-123` is executed
- **THEN** the review SHALL be skipped
- **AND** output SHALL indicate "Skipped: ticket has no-review tag"

### Requirement: Autonomous Execution Loop

The os-tk workflow SHALL provide autonomous queue processing via the `/tk-run` command.

#### Scenario: Run processes queue until empty

- **GIVEN** the ready queue contains tickets [T-1, T-2, T-3]
- **WHEN** `/tk-run --ralph` is executed
- **THEN** for each ticket in queue order:
  - `/tk-start <id>` SHALL be called
  - `/tk-done <id>` SHALL be called
  - `/tk-review <id>` SHALL be called (if `reviewer.autoTrigger == true`)
- **AND** the loop SHALL exit when `tk ready` returns no tickets

#### Scenario: Run respects max-cycles limit

- **GIVEN** `/tk-run --max-cycles 5` is executed
- **WHEN** 5 iterations complete
- **THEN** the loop SHALL exit
- **AND** output SHALL indicate "Max cycles (5) reached"

#### Scenario: Run exits on critical fix ticket

- **GIVEN** `/tk-review` creates a P0 (critical) fix ticket
- **WHEN** the review step completes
- **THEN** the `/tk-run` loop SHALL exit immediately
- **AND** output SHALL indicate "Critical issue found, stopping for human review"

### Requirement: Reviewer Agent Role

The `os-tk-reviewer` agent SHALL analyze completed work without modifying code.

#### Scenario: Reviewer reads specs and code

- **GIVEN** the `os-tk-reviewer` agent is invoked for ticket T-123
- **WHEN** analyzing the implementation
- **THEN** the agent SHALL read:
  - The git diff for the ticket's merge commit
  - The OpenSpec specs referenced by the ticket's epic
  - The ticket's acceptance criteria

#### Scenario: Reviewer creates tickets but not code

- **GIVEN** the `os-tk-reviewer` agent finds issues
- **WHEN** creating fix tickets
- **THEN** the agent SHALL have permission to run `tk create`, `tk add-note`, `tk link`
- **AND** the agent SHALL NOT edit code files (*.py, *.ts, *.js, etc.)
- **AND** the agent SHALL NOT run `tk start` or `tk close`

### Requirement: Reviewer Configuration

The `.os-tk/config.json` SHALL support a `reviewer` section for review behavior.

#### Scenario: Default reviewer config

- **GIVEN** `os-tk init` is run on a new project
- **WHEN** `.os-tk/config.json` is created
- **THEN** the config SHALL include a `reviewer` section with:
  - `autoTrigger`: false
  - `categories`: ["spec-compliance", "tests", "security", "quality"]
  - `requireSeverity`: ["error"]
  - `requireConfidence`: 80
  - `hybridFiltering`: true
  - `skipTags`: ["no-review", "wip"]
  - `scouts`: role-based entries with `role` and `model`
