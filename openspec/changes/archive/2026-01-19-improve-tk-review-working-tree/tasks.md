# Tasks: Improve /tk-review (Working Tree + Role Scouts)

## Epic

- Update OpenCode OS-TK review pipeline for pre-merge reviews and better scout diversity.

## Tickets

1. **Commands**
   - Add `--working-tree` and `--base` to `/tk-review`.
   - Support working-tree diff source in `/tk-review-fast` and `/tk-review-strong`.
   - Add config-path fallback to these commands.

2. **Agents (OpenCode)**
   - Add `os-tk-review-router` agent and use it from `/tk-review`.
   - Add role-based rubrics to generated scouts via `reviewer.scouts[].role`.

3. **Config + Docs**
   - Extend `config.json` to include `reviewer.scouts[].role` for defaults.
   - Document working-tree mode and scout roles in `docs/configuration.md`.

4. **Verification**
   - Run a local smoke check by invoking `/tk-review` contracts against a branch with uncommitted changes.
