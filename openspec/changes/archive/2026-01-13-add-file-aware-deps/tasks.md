## 1. Agent Rename

- [x] 1.1 Create `os-tk-orchestrator.md` with expanded role description ✅
- [x] 1.2 Update `os-tk` CLI `rebuild_agent_from_template()` for new agent name ✅
- [x] 1.3 Delete `os-tk-bootstrapper.md` ✅
- [x] 1.4 Update `OPENCODE_FILES` array in `os-tk` to include new filename ✅

## 2. Update `/tk-bootstrap` Command

- [x] 2.1 Change agent reference from `os-tk-bootstrapper` to `os-tk-orchestrator` ✅
- [x] 2.2 Add Step 3b: File prediction requirements ✅
- [x] 2.3 Add instructions for writing `files-modify`/`files-create` to frontmatter ✅
- [x] 2.4 Update examples to show file prediction output ✅

## 3. Update `/tk-queue` Command

- [ ] 3.1 Change agent reference to `os-tk-orchestrator`
- [x] 3.2 Update argument parsing: `--next`, `--all`, `--change <id>` ✅
- [x] 3.3 Add Step 2b: Ensure file predictions exist ✅
- [x] 3.4 Add Step 2c: File overlap detection and `tk dep` injection ✅
- [x] 3.5 Add Step 2d: Conflict check against `in_progress` tickets (for `--next`) ✅
- [x] 3.6 Update COMMAND CONTRACT to allow `tk dep` and ticket editing ✅
- [x] 3.7 Update output format to show overlap resolution ✅

## 4. Update Config Schema

- [x] 4.1 Add `fileAwareDeps` section to `default_config()` in `os-tk` ✅
- [x] 4.2 Document new config options in README or inline comments ✅

## 5. Update Related Files

- [x] 5.1 Update `skill/ticket/SKILL.md` to mention file-aware deps ✅
- [ ] 5.2 Update `command/plan.md` if it references bootstrapper
- [ ] 5.3 Update `AGENTS.md` block template with new workflow info

## 6. Testing & Validation

- [ ] 6.1 Test `/tk-bootstrap` generates file predictions
- [ ] 6.2 Test `/tk-queue --all` detects overlaps and adds deps
- [ ] 6.3 Test `/tk-queue --next` excludes conflicting tickets
- [ ] 6.4 Test `tk query` correctly exposes file fields
- [ ] 6.5 Verify `os-tk apply` generates correct agent files
