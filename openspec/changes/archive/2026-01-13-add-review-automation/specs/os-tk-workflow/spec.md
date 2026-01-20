## ADDED Requirements

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
- **WHEN** `reviewer.createTicketsFor` includes the issue severity
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
- **WHEN** `/tk-run --all` is executed
- **THEN** for each ticket in queue order:
  - `/tk-start <id>` SHALL be called
  - `/tk-done <id>` SHALL be called
  - `/tk-review <id>` SHALL be called (if `reviewer.autoTrigger == "on-done"`)
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
  - `model`: defaults to planner.model value
  - `autoTrigger`: "manual"
  - `categories`: ["spec-compliance", "tests", "security", "quality"]
  - `createTicketsFor`: ["error"]
  - `skipTags`: ["no-review", "wip"]
