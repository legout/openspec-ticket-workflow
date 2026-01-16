---
description: Review a completed ticket using multi-model adaptive aggregation
---

# /tk-review <ticket-id> [options]

**Arguments:** $ARGUMENTS

## Pre-execution Check
Check if the `subagent` extension is installed by checking for the `subagent` tool. If not available, instruct the user to install it globally at `~/.pi/agent/extensions/subagent`.

## Step 1: Validation and Context

Read `.os-tk/config.json` and check `skipTags`.
Ensure ticket is closed: `tk show $1`.

## Step 2: Global-Style Flag Parsing (New 7-Scout System)

Parse arguments for these flags (highest to lowest precedence):

1. **Manual role selection**: `--scouts ROLE,ROLE` (bypasses all logic)
2. **Specialized reviewer flags**:
   - `--spec-audit`: Run spec-audit role only
   - `--shallow-bugs`: Run shallow-bugs role only (alias: `--fast`)
   - `--history-context`: Run history-context role only (alias: `--deep`)
   - `--code-comments`: Run code-comments role only
   - `--intentional-check`: Run intentional-check role only
3. **Flexible provider flags**:
   - `--fast-sanity`: Run fast-sanity role only
   - `--second-opinion`: Run second-opinion role only (alias: `--seco`)
4. **Meta flags**:
   - `--ultimate`: Run all 7 role-based scouts + STRONG aggregator
   - `--standard`: Run default set (shallow-bugs, spec-audit)
5. **Legacy aliases** (for backwards compatibility):
   - `--fast` → alias for `--shallow-bugs`
   - `--seco` → alias for `--second-opinion`
6. **No flags**: Use adaptive complexity-based selection (default OS-TK behavior)

## Role-to-Scout Selection

When role-based flags are used:

1. Load `reviewer.scouts[]` from config
2. For each requested role, select the scout with matching `role` field
3. Valid roles: `spec-audit`, `shallow-bugs`, `history-context`, `code-comments`, `intentional-check`, `fast-sanity`, `second-opinion`
4. If a role is missing from config, error with clear message

## Adaptive Selection (No Flags)

When no reviewer flags present, use complexity-based routing:

- **SMALL** (≤4 files, ≤200 lines) AND NOT risky:
  - Scouts: `shallow-bugs`, `spec-audit`
  - Aggregator: FAST

- **MEDIUM** (≤12 files, ≤800 lines) AND NOT risky:
  - Scouts: `shallow-bugs`, `spec-audit`, `history-context`
  - Aggregator: FAST

- **LARGE / RISKY** (else):
  - Scouts: All 7 roles (shallow-bugs, spec-audit, history-context, code-comments, intentional-check, fast-sanity, second-opinion)
  - Aggregator: STRONG

## Ultimate Mode Special Behavior

- `--ultimate` ⇒ **always use STRONG aggregator** (regardless of diff size/risk)
- `--ultimate` + `--force-fast` ⇒ conflict error (mutually exclusive)

## Step 3: Routing Logic

1. Find the merge commit: `git log --oneline --grep=\"$1\" -1`.
2. Get diff stats:
   - `files_changed`: `git show --name-only <sha> | wc -l`
   - `lines_changed`: `git diff --shortstat <sha>^..<sha>`
3. Identify **risk signals**:
   - Check if diff touches: `auth`, `security`, `crypto`, `migrations`, `lockfile`, `config`.

## Step 3: Routing Logic

Based on `reviewer.adaptive` config:

- **SMALL**: (files <= 4 AND lines <= 200) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: `mini`. (Add more scouts if needed)
- **MEDIUM**: (files <= 12 AND lines <= 800) AND NOT risky
  - Use **FAST** aggregator.
- **LARGE / RISKY**: (else)
  - Use **STRONG** aggregator.

## Step 4: Delegate

Use `subagent` tool to run the review pipeline:
1. Spawn scouts in parallel using `subagent.parallel`.
2. Spawn aggregator using `subagent.single` to merge results.

---

## EXECUTION CONTRACT

This command acts as an **orchestrator and router**. It computes complexity and delegates the actual review to the multi-model aggregator subtask via the Pi `subagent` extension.
