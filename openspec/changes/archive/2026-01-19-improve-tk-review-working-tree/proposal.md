# Improve /tk-review: Working Tree Mode + Role-Based Scouts

**Status:** Draft

## Overview

Extend the OS-TK code review workflow to support reviewing **unmerged working tree diffs** while keeping the existing post-merge review flow.

In addition, improve review signal quality by introducing **role-diverse review scouts** (fast/standard/deep/second-opinion) while retaining OS-TK’s structured envelope + aggregation + auto-fix-ticket creation pipeline.

## Goals

1. **Working Tree Reviews**
   - `/tk-review <ticket> --working-tree` reviews the current branch’s unmerged changes against a configurable base (default: `mainBranch`).
   - Always writes a review note to the ticket.
   - Creates fix tickets for findings meeting `reviewer.requireSeverity`.

2. **Role-Based Review Scouts**
   - Scouts are differentiated by review rubric (“roles”), not only by model.
   - Multi-model review remains supported and configurable.

3. **Portability**
   - Configuration remains portable via repo `config.json` / `.os-tk/config.json`.
   - No reliance on user-global `~/.config/opencode`.

## Non-Goals

- Replacing the existing merge-commit review pipeline.
- Preventing duplicate fix tickets during iterative reviews (handled by `/tk-refactor`).

## Requirements

### R1: Working Tree Review Mode

Add `--working-tree` support to `/tk-review`, `/tk-review-fast`, and `/tk-review-strong`.

**Behavior:**
- Determine `baseRef` (flag `--base <ref>` or config `mainBranch`).
- Compute `baseSha = git merge-base <baseRef> HEAD`.
- Use `git diff <baseSha>` as the review diff.
- Always execute `tk add-note <ticket-id> ...` with consolidated results.
- Create fix tickets based on `reviewer.requireSeverity`.

**Acceptance:**
- [ ] `/tk-review T-123 --working-tree` works before merge.
- [ ] Review note is added every run.
- [ ] Fix tickets are created for `error` findings.

### R2: Config Path Fallback

All OS-TK commands should prefer `.os-tk/config.json` but fall back to root `config.json`.

**Acceptance:**
- [ ] Commands work in repos without `.os-tk/`.

### R3: Role-Based Scouts

Extend `reviewer.scouts[]` to optionally include a `role` field.

**Default roles:**
- `fast-sanity`
- `standard`
- `deep`
- `second-opinion`

**Acceptance:**
- [ ] Generated scout agents include role-specific rubrics.
- [ ] Envelope schema stays unchanged.

### R4: Review Router Agent

Introduce a dedicated read-only router agent for `/tk-review` orchestration, delegating execution to the existing fast/strong aggregators.

**Acceptance:**
- [ ] `/tk-review` uses the router agent.
- [ ] Aggregators remain the exclusive writers (`tk add-note`, `tk create`, `tk link`).

## Implementation Plan

See `tasks.md`.
