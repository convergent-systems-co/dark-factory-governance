# Rename ai-submodule to Dark Factory Governance in Documentation

**Author:** Code Manager (agent)
**Date:** 2026-02-27
**Status:** approved
**Issue:** https://github.com/SET-Apps/ai-submodule/issues/444
**Branch:** NETWORK_ID/docs/444/rename-to-dark-factory

---

## 1. Objective

Rename all documentation references from "ai-submodule" to "Dark Factory Governance" while preserving git repo URLs (linking to ai-submodule repo with display text "Dark Factory Governance").

## 2. Rationale

The project's proper name is "Dark Factory Governance" but documentation inconsistently refers to it as "ai-submodule" (the git repo name). This creates confusion for new adopters.

| Alternative | Considered | Rejected Because |
|-------------|-----------|------------------|
| Rename the git repo | Yes | Explicitly out of scope per issue |
| Only rename in top-level docs | Yes | Inconsistent naming is confusing |

## 3. Scope

### Files to Create

None.

### Files to Modify

| File | Change Description |
|------|-------------------|
| `CLAUDE.md` | Replace "ai-submodule" text references with "Dark Factory Governance" |
| `instructions.md` | Replace "ai-submodule" text references |
| `README.md` | Replace "ai-submodule" text references |
| `GOALS.md` | Replace "ai-submodule" text references |
| `docs/**/*.md` | Replace text references; preserve git URLs with updated display text |
| `governance/prompts/*.md` | Replace text references |
| `governance/personas/agentic/*.md` | Replace text references |

### Files to Delete

None.

## 4. Approach

1. Search all `.md` files for "ai-submodule" to build complete occurrence list
2. Categorize each occurrence: text reference (replace), git URL (keep URL, update display text), path reference (keep as-is), config reference (keep as-is)
3. Apply replacements file by file
4. Verify no broken links or references

## 5. Testing Strategy

| Test Type | Coverage | Description |
|-----------|----------|-------------|
| Manual | All modified files | Verify no broken links |
| Grep | All `.md` files | Confirm no remaining text-context references |

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Accidentally renaming git URLs | Medium | Medium | Categorize each occurrence first |
| Breaking config references | Low | High | Exclude `.yaml` files |

## 7. Dependencies

- [ ] None

## 8. Backward Compatibility

No breaking changes — documentation-only.

## 9. Governance

| Panel | Required | Rationale |
|-------|----------|-----------|
| documentation-review | Yes | Primary documentation change |

**Policy Profile:** default
**Expected Risk Level:** low

## 10. Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-02-27 | Keep git URLs unchanged | Issue explicitly states only doc text should change |
| 2026-02-27 | Preserve path references (.ai/) | Filesystem paths refer to actual directory names |
