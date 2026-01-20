# Align /tk-review with Global Code-Review UX

**Status:** Draft

**External Ref:** Related to `improve-tk-review-working-tree` (extends it with global-style flags)

## Overview

Enhance `/tk-review` to accept **global code-review style flags** (`--fast`, `--deep`, `--seco`, `--ultimate`, `--standard`) while preserving OS-TK's adaptive multi-model aggregation engine, structured envelope output, and automatic fix-ticket creation.

**Key principle:** Global UX (flag names + roles + one reviewer per role), OS-TK engine (adaptive scouting + deterministic aggregation + tk integration).

## Goals

1. **Global-Style Flag Interface**
   - `/tk-review` accepts `--ultimate`, `--fast`, `--deep`, `--seco`, `--standard` flags.
   - Flags map to **roles** (`fast-sanity`, `standard`, `deep`, `second-opinion`), not hard-coded scout IDs.
   - One reviewer per role (config validation enforces this).

2. **Precedence Rules**
   - `--scouts ID,ID` (manual override) takes highest priority.
   - Reviewer flags (`--fast`/`--deep`/`--seco`/`--ultimate`/`--standard`) override adaptive defaults.
   - Otherwise, use existing adaptive complexity-based selection (OS-TK advantage).

3. **Ultimate Mode Behavior**
   - `--ultimate` runs all 4 role-based scouts.
   - `--ultimate` **always uses STRONG aggregator** (per user requirement).
   - `--ultimate` + `--force-fast` is treated as a conflict (error).

4. **Model Mapping via Config**
   - All model mappings remain in `config.json` / `.os-tk/config.json` under `reviewer.scouts[]`.
   - `os-tk apply` regenerates scout agents from config (already works).

5. **Safety & Contracts**
   - Scouts are **read-only** (permissions, not just prompts).
   - Aggregators are **exclusive writers** (`tk add-note`, `tk create`, `tk link`).
   - Router remains read-only orchestrator.

## Non-Goals

- Changing global `~/.config/opencode` code-review (it's the source of truth).
- Removing OS-TK's adaptive complexity-based routing (it becomes the default when no flags).
- Removing existing `--working-tree` or `--base` functionality (keep it).

## Requirements

### R1: Flag Interface

Add global-style reviewer flags to `/tk-review` command.

**Flags:**
- `--ultimate`: Run all 4 role-based scouts, use STRONG aggregator.
- `--fast`: Run only `fast-sanity` role scout.
- `--deep`: Run only `deep` role scout.
- `--seco`: Run only `second-opinion` role scout.
- `--standard`: Run only `standard` role scout (default when no flags).
- `--scouts ID,ID`: Manual scout selection (overrides flags, highest priority).

**Acceptance:**
- [ ] `/tk-review T-123 --fast` uses only the first scout with `role: "fast-sanity"`.
- [ ] `/tk-review T-123 --deep` uses only the first scout with `role: "deep"`.
- [ ] `/tk-review T-123 --seco` uses only the first scout with `role: "second-opinion"`.
- [ ] `/tk-review T-123 --ultimate` runs all 4 role scouts + STRONG aggregator.
- [ ] `/tk-review T-123 --scouts grok,mini` overrides all flags (works as before).
- [ ] `/tk-review T-123` (no flags) keeps adaptive behavior (current OS-TK default).

### R2: Role-to-Scout Mapping

Flags select scouts by **role** from `reviewer.scouts[]` config, not by hard-coded IDs.

**Role values:**
- `fast-sanity` (mapped by `--fast`)
- `standard` (mapped by `--standard`, default)
- `deep` (mapped by `--deep`)
- `second-opinion` (mapped by `--seco`)

**Acceptance:**
- [ ] Router selects first matching scout for each requested role.
- [ ] If a role is missing from config, clear error message tells user to add it.
- [ ] Config can have additional scouts (ignored unless selected via `--scouts`).

### R3: One Reviewer Per Role

System enforces **at most one scout per role** in config.

**Acceptance:**
- [ ] `os-tk apply` validates `reviewer.scouts[]` has no duplicate roles.
- [ ] Error message: `"Duplicate role '${role}' in reviewer.scouts. Only one scout per role allowed."`

### R4: Ultimate Mode ⇒ STRONG Aggregator

When `--ultimate` is used, always delegate to STRONG aggregator regardless of diff size/risk.

**Acceptance:**
- [ ] `/tk-review T-123 --ultimate` on SMALL diff still uses STRONG aggregator.
- [ ] `/tk-review T-123 --ultimate --force-fast` errors with conflicting flags.

### R5: Scout Permissions (Read-Only Enforcement)

Scouts are **read-only by permissions**, not just by prompt contract.

**Permissions:**
- Allow: `git *`, file read tools
- Disallow: `tk *`, file edit/write tools

**Acceptance:**
- [ ] Generated scout agent files have restrictive permissions.
- [ ] Scout generation (`rebuild_scout_from_template()` in `os-tk`) enforces this.

### R6: Router Agent Flag Semantics

Router agent explicitly implements flag precedence and role mapping in its system prompt.

**Acceptance:**
- [ ] Router agent describes parsing `--fast`, `--deep`, `--seco`, `--standard`, `--ultimate`.
- [ ] Router describes precedence: `--scouts` > flags > adaptive.
- [ ] Router describes role-based selection from `reviewer.scouts[]`.

### R7: Cross-Platform Consistency

Flags work consistently across `opencode/`, `claude/`, `factory/`, `pi/`.

**Acceptance:**
- [ ] `opencode/command/tk-review.md` has full multi-scout implementation.
- [ ] `claude/command/tk-review.md` accepts flags (single-agent fallback).
- [ ] `factory/command/tk-review.md` accepts flags (single-agent fallback).
- [ ] `pi/prompts/tk-review.md` accepts flags (multi-scout via Pi subagent extension).

## Implementation Plan

See `tasks.md`.
