# Change: Review Pipeline Refactor v2 (4 Roles + Lead, Gate-First)

## Why

The current review system is complex (adaptive routing, 7 scouts, 2 aggregators) and non-deterministic, which makes reviews harder to reason about and inconsistent as a quality gate. We need a simpler, deterministic pipeline that enforces review before closing tickets.

## What Changes

- Replace adaptive routing with **4 role reviewers + 1 lead reviewer**.
- Make review a **gate** by default: `/tk-done` refuses unless the latest review is PASS for the current HEAD/diff hash.
- Define deterministic review inputs/outputs (merge-base diff, structured envelopes, consolidated note).
- Introduce config v2 (`reviewer.roles`, policy + thresholds) with legacy `reviewer.scouts` migration and warning.
- Update CLI flags: new `--roles`, `--policy`, `--base`; deprecate old fast/strong flags.
- Apply the new reviewers and commands across OpenCode, Claude, Factory, and Pi.

## Impact

- **Affected specs:** `openspec/specs/os-tk-workflow/spec.md`
- **Affected areas:**
  - Review agents and commands across `opencode/`, `claude/`, `factory/`, `pi/`
  - `os-tk` generator + config defaults/migration
  - `docs/` (configuration, workflow, migration) and `AGENTS.md`
  - Tests (`tests/test-review-refactor.sh`)

## Success Criteria

1. `/tk-review` (ticket open) runs the 4 role reviewers in parallel, then a lead reviewer that writes a single consolidated summary with base/head/merge-base/diffHash metadata.
2. PASS/FAIL is deterministic and config-driven; warnings do not block in `gate` policy.
3. `/tk-done` enforces a PASS review for current HEAD/diffHash; optional `autoRerunOnDone` guardrails are respected.
4. `reviewer.roles` config works and legacy `reviewer.scouts` auto-migrates with a warning.
5. Role/lead agents and updated commands exist on all platforms; old scouts/aggregators and fast/strong commands are removed.
6. Docs and skills reflect gate-first workflow and new flags.
7. Tests validate the refactor and pass.
