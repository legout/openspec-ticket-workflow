# Tasks: Review Pipeline Refactor v2

## 1. OpenCode Review Pipeline
- [ ] 1.1 Add role reviewer + lead reviewer agent templates (OpenCode)
- [ ] 1.2 Update `opencode/command/tk-review.md` for roles/policy/base flags + open-ticket requirement
- [ ] 1.3 Remove old scouts/aggregators and fast/strong commands

## 2. Gate-First Workflow
- [ ] 2.1 Update `/tk-done` to enforce PASS review for current HEAD/diffHash
- [ ] 2.2 Update `/tk-run` sequence to start → review → done
- [ ] 2.3 Update workflow skill with new gate-first behavior

## 3. Config v2 + Generator
- [ ] 3.1 Update `os-tk` sync/apply for reviewer.roles
- [ ] 3.2 Implement legacy scouts migration with warning
- [ ] 3.3 Update default config to v2 schema

## 4. Platform Ports
- [ ] 4.1 Add role + lead reviewers for Claude/Factory/Pi
- [ ] 4.2 Update tk-review entrypoints for all platforms
- [ ] 4.3 Remove old scout/aggregator templates across platforms

## 5. Docs + Migration
- [ ] 5.1 Update configuration + workflow docs for v2
- [ ] 5.2 Update README + AGENTS.md
- [ ] 5.3 Add reviewer migration guide

## 6. Tests
- [ ] 6.1 Add test-review-refactor.sh
- [ ] 6.2 Validate refactor assertions and run tests
