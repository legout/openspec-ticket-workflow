## ADDED Requirements

### Requirement: Template-Based Platform Rendering
The os-tk workflow SHALL generate platform-specific agents, commands/prompts, and skills from shared templates derived from opencode content.

#### Scenario: Init renders platform outputs
- **WHEN** `os-tk init` is executed for a set of platforms
- **THEN** the tool SHALL render platform files from templates
- **AND** write the generated files to each platform directory

#### Scenario: Apply re-renders deterministically
- **WHEN** `os-tk apply` is executed
- **THEN** the tool SHALL re-render templates using current config values
- **AND** produce deterministic outputs without network access

### Requirement: Opencode Source-of-Truth Sync
The os-tk workflow SHALL treat opencode templates as the canonical source and limit platform-specific deltas to overlays (frontmatter, directory layout, and platform checks).

#### Scenario: Platform overlay injection
- **GIVEN** a platform overlay adds a Pi subagent pre-execution check
- **WHEN** templates are rendered for the Pi platform
- **THEN** the output SHALL include the overlay content
- **AND** preserve the opencode-derived workflow body

### Requirement: Platform Asset Synchronization
The os-tk workflow SHALL synchronize platform-specific agents, commands/prompts, and skills from templates for each configured platform.

#### Scenario: Sync covers all asset types
- **WHEN** platform outputs are rendered
- **THEN** the tool SHALL generate agents, commands/prompts, and skills
- **AND** place them in the platform-specific directories

#### Scenario: Platform directory mapping
- **WHEN** templates are rendered for each platform
- **THEN** opencode outputs SHALL use `agent/`, `command/`, `skill/`
- **AND** claude outputs SHALL use `agents/`, `commands/`, `skills/`
- **AND** factory outputs SHALL use `droids/`, `commands/`, `skills/`
- **AND** pi outputs SHALL use `agents/`, `prompts/`, `skills/`

#### Scenario: Drift reconciliation on apply
- **GIVEN** a platform file diverges from rendered output
- **WHEN** `os-tk apply` is executed
- **THEN** the file SHALL be overwritten with the rendered template output

### Requirement: Template Source Synchronization
The os-tk workflow SHALL fetch template sources and re-render platform outputs during `os-tk sync`.

#### Scenario: Sync refreshes templates and outputs
- **WHEN** `os-tk sync` is executed for a platform
- **THEN** the tool SHALL download the latest templates from the template repository
- **AND** re-render the platform outputs using those templates

#### Scenario: Sync respects platform scope
- **GIVEN** `os-tk sync --agent pi` is executed
- **WHEN** the sync completes
- **THEN** only Pi platform outputs SHALL be updated
- **AND** other platform directories SHALL remain unchanged

#### Scenario: Sync is deterministic
- **GIVEN** templates and config have not changed
- **WHEN** `os-tk sync` is executed twice
- **THEN** the second run SHALL produce no file diffs

#### Scenario: Sync errors on missing templates
- **GIVEN** a required template file is missing
- **WHEN** `os-tk sync` is executed
- **THEN** the command SHALL fail with a clear error
