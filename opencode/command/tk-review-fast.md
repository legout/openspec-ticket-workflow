---
description: Run multi-scout code review using the FAST aggregator
agent: os-tk-reviewer-agg-fast
subtask: true
---

# /tk-review-fast <ticket-id> [options]

**Arguments:** $ARGUMENTS

## Step 1: Initialize

1. Parse \`--scouts\` list.
2. Find merge commit SHA for \`<ticket-id>\`.
3. Load OpenSpec proposal and specs for context.

## Step 2: Build Review Packet

Assemble a consistent "Review Packet" that all scouts will receive:

1. **Ticket Context:**
   - `tk show <ticket-id>` output (already fetched)
   
2. **Diff Content:**
   - Run the computed `diff_command` to get the git diff
   - Extract file list: `git diff --name-only <range>`
   - Get stats: `git diff --shortstat <range>`

3. **OpenSpec Context** (if available):
   - Load proposal from epic's `external_ref` (format: `openspec:<change-id>`)
   - Read `proposal.md`, `design.md` (if present), `tasks.md` (if present)

4. **Risk Signals Summary:**
   - Note if diff touches: `auth`, `security`, `crypto`, `migrations`, `lockfile`, `config`

This Review Packet ensures all scouts analyze the same context.

## Step 3: Run Review Scouts (Parallel)

For each scout in the list:
1. Spawn a subtask using the scout's agent: `os-tk-reviewer-scout-<id>`.
2. Instruction: "Review the implementation for <ticket-id> using this Review Packet. Output your findings in the @@OS_TK_SCOUT_RESULT_START@@ JSON envelope."
3. Provide the complete Review Packet (ticket context, diff, OpenSpec specs, risk signals).
4. Run up to `--parallel` (default 3) in parallel.

## Step 4: Aggregate and Merge

1. Collect all envelopes.
2. Deduplicate findings:
   - Match by (category, title, file).
   - Resolve severity: use the MAX level among reporting scouts.
   - Record "Sources" for each finding.
3. If any scout marked finding severity in \`reviewer.createTicketsFor\`:
   - Prepare fix ticket details.
   - Guardrail: if \`error\` but no file:line evidence, downgrade to \`warning\`.

## Step 5: Write Results (EXCLUSIVE WRITER)

1. **Add Note**: Call \`tk add-note <ticket-id> "<consolidated-markdown>"\`.
2. **Create Tickets**: For each merged finding meeting threshold:
   - Call \`tk create "Fix: <title>" --parent <epic-id> --description "<desc> sources: <scouts>"\`.
   - Call \`tk link <new-id> <ticket-id>\`.

## Step 6: Final Summary

Print a brief summary of findings and created tickets.
