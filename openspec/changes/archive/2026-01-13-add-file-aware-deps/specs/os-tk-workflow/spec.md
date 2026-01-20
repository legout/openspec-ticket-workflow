## ADDED Requirements

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
