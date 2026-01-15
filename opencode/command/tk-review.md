---
description: Review a completed ticket using multi-model adaptive aggregation [ulw]
agent: os-tk-reviewer
---

# /tk-review <ticket-id> [options]

**Arguments:** $ARGUMENTS

## Step 1: Validation and Context

Read `.os-tk/config.json` and check `skipTags`.
Ensure ticket is closed: \`tk show <ticket-id>\`.

## Step 2: Adaptive Complexity Scoring

1. Find the merge commit: \`git log --oneline --grep="<ticket-id>" -1\`.
2. Get diff stats:
   - \`files_changed\`: \`git show --name-only <sha> | wc -l\`
   - \`lines_changed\`: \`git diff --shortstat <sha>^..<sha>\`
3. Identify **risk signals**:
   - Check if diff touches: \`auth\`, \`security\`, \`crypto\`, \`migrations\`, \`lockfile\`, \`config\`.

## Step 3: Routing Logic

Based on \`reviewer.adaptive\` config:

- **SMALL**: (files <= 4 AND lines <= 200) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: \`grok\`, \`mini\`.
- **MEDIUM**: (files <= 12 AND lines <= 800) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: \`grok\`, \`gpt52\`.
- **LARGE / RISKY**: (else)
  - Use **STRONG** aggregator.
  - Default scouts: \`grok\`, \`gpt52\`, \`opus45\`.

### Manual Overrides

- `--all-scouts`: Run all configured scouts.
- `--scouts ID,ID`: Run specific subset.
- `--no-adaptive`: Skip heuristic, use LARGE/STRONG defaults.
- `--force-strong` / `--force-fast`: Override aggregator choice.

### Global-Style Reviewer Flags

These flags select reviewers by **role** (from `reviewer.scouts[]` config):

- `--ultimate`: Run all 4 role-based scouts (fast-sanity, standard, deep, second-opinion) + **STRONG aggregator**.
- `--fast`: Run only the first scout with `role: "fast-sanity"`.
- `--standard`: Run only the first scout with `role: "standard"`.
- `--deep`: Run only the first scout with `role: "deep"`.
- `--seco`: Run only the first scout with `role: "second-opinion"`.

**Precedence rules (highest to lowest):**
1. `--scouts ID,ID` (manual scout selection, bypasses roles)
2. Global-style flags (`--ultimate`, `--fast`, `--deep`, `--seco`, `--standard`)
3. Adaptive complexity-based selection (default when no flags)

**Role mapping:**
- Flags select scouts by **role** from `config.json` / `.os-tk/config.json` → `reviewer.scouts[]`.
- One reviewer per role enforced by `os-tk apply` validation.
- If a requested role is missing from config, error with clear message.

**Ultimate mode behavior:**
- `--ultimate` ⇒ always uses STRONG aggregator (regardless of diff size/risk).
- `--ultimate` + `--force-fast` ⇒ conflict error (mutually exclusive).

## Step 4: Delegate

Call the appropriate internal command with selected scouts:

\`\`\`bash
/tk-review-<fast|strong> <ticket-id> --scouts <list> [options]
\`\`\`

---

## EXECUTION CONTRACT

This command acts as an **orchestrator and router**. It computes complexity and delegates the actual review to the multi-model aggregator subtask.
