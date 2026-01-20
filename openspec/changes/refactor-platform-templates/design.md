## Context
Platform-specific directories (`opencode/`, `pi/`, `factory/`, `claude/`) contain duplicated agents, commands/prompts, and skills. These files drift because updates land in one platform and are copied inconsistently to others. The project intends **opencode to be the source of truth** for workflow semantics, with small platform-specific adjustments (frontmatter, directory layout, extensions).

## Goals / Non-Goals
- Goals:
  - Centralize shared content in templates derived from opencode.
  - Render platform outputs deterministically during `os-tk sync`/`os-tk init`/`os-tk apply`.
  - Preserve necessary platform-specific frontmatter and checks.
  - Make drift visible via validation or diff checks.
- Non-Goals:
  - Redesign the os-tk workflow itself (only align to opencode semantics).
  - Replace the OpenSpec/tk tooling or change runtime behavior beyond sync.

## Deep Analysis: Platform Sync Strategy

### 1) Structural Differences (layout)
- opencode: `agent/`, `command/`, `skill/`
- claude: `agents/`, `commands/`, `skills/`
- factory: `droids/`, `commands/`, `skills/`
- pi: `agents/`, `prompts/`, `skills/`

**Sync implication:** template renderer must map logical asset types to platform-specific directories.

### 2) Frontmatter & execution contract differences
- opencode commands often include `agent:` and `[ulw]` tags; some add `subtask`/`background`.
- claude/factory commands use `argument-hint` + `allowed-tools`.
- pi prompts are minimal and add pre-execution checks for the `subagent` extension.

**Sync implication:** frontmatter is a platform overlay, not shared content. Templates should isolate frontmatter blocks from shared body content.

### 3) Agent content drift
- Planner: opencode is view-only (`edit/write: deny`, planning + review) vs others allow bootstrapping/orchestration and `edit/write: allow`.
- Worker: same content, different temperature (`0.2` vs `0.75`).
- Orchestrator + advisors + role reviewers: effectively identical across platforms.

**Sync implication:** agent templates should support role-specific parameters (model/temp/reasoning) and platform overrides for permissions + role scope.

### 4) Skill content drift
- `os-tk-workflow`: opencode is the most complete and **gate-first** (start → review → done); pi/claude/factory are shorter and still reference older pipelines.
- `openspec` and `ticket`: opencode/pi contain shorter operational logic; claude/factory include CLI reference + templates.
- `tk-frontmatter`: identical everywhere.

**Sync implication:** opencode content should be canonical; platform overlays may add/remove small pre-exec checks, but not alter workflow semantics.

### 5) Command content drift
- `tk-done`: opencode includes review gate enforcement + auto-rerun guardrails; other platforms are simplified/older.
- `tk-run`: opencode contains explicit cycle logic; other platforms are stubs.
- `tk-start`: opencode contains full logic + parallelism; pi adds a subagent pre-check.
- `tk-review`: body largely aligned, but frontmatter varies.

**Sync implication:** command bodies should be shared (opencode), with platform frontmatter overlays and optional injected pre-check sections.

### 6) Source-of-truth policy
- Treat opencode as canonical for **content** (workflow logic, steps, rules).
- Platform-specific deltas limited to:
  - Frontmatter format
  - Directory layout
  - Pre-execution checks (e.g., Pi subagent extension)

**Sync implication:** any semantic changes should land in opencode templates first, then render out to other platforms.

## Decisions
- Decision: Create a template system with **shared content** derived from opencode and **platform overlays** for frontmatter and small platform-specific inserts.
- Decision: `os-tk sync` downloads templates and re-renders platform outputs; `os-tk init` invokes sync + apply; `os-tk apply` re-renders without network.
- Decision: Add validation to detect drift between rendered outputs and committed platform files.

## Risks / Trade-offs
- Risk: Template renderer adds complexity to `os-tk` CLI (bash-based). → Mitigate with a minimal, deterministic templating layer and tests.
- Risk: Existing platform-specific behavior may be lost. → Mitigate by documenting required deltas and encoding them as overlays/conditionals.
- Risk: Large file churn during migration. → Mitigate via staged rollout and diff validation.

## Migration Plan
1. Inventory files and codify shared vs platform-specific deltas (this change).
2. Build template directories and render manifest.
3. Migrate opencode content into shared templates.
4. Add platform overlays and conditional inserts (frontmatter, subagent checks).
5. Update `os-tk sync`/`os-tk init`/`os-tk apply` to render outputs.
6. Validate rendered outputs against expected platform layouts; update docs.

## Open Questions
- Which platform-specific deltas must remain (beyond frontmatter)?
- Should templates live inside the repo or remain remote-only via `templateRepo`?
- Do we need a formal `os-tk apply --check` mode for CI drift detection?
