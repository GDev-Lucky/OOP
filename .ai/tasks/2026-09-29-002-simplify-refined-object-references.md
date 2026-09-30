# Task: Simplify refined object references

- Status: completed
- importance: 0.80
- confidence: 0.80
- createdAt: 2026-09-29T00:00:00Z
- lastUsedAt: 2026-09-29T00:00:00Z

## Description

Replace `Object<T>` marker semantics with bare `Object` in `Refine` overrides; preserve base object references for inherited `Class` members. Remove unused generic Object handling and validate tests.

## Context

See `src/types.luau`, `tests/test4.luau`, `docs/api-reference.md`. Existing user edit in `tests/test3.luau` must remain untouched.

## Decisions

Keep `Object` non-generic and record override origin in metadata. See `.ai/decision/2026-09-29-001-bare-object-refinement.md`.

## Likely Files

`src/types.luau`, `tests/test4.luau`, `docs/api-reference.md`, `docs/limitations.md`.

## Files Touched

`src/types.luau`, `tests/test4.luau`, `docs/api-reference.md`, `docs/limitations.md`, `.ai/tasks/current.md`, this record, `.ai/decision/latest.md`, and a new dated decision record.

## Summary

Removed generic Object marker handling. `Refine` overrides use bare `Object` for the refined view; inherited members keep base references using a metadata origin flag. `ObjectOf<Base>` explicitly denotes base returns in overrides. Updated dedicated tests and docs.

## Validation

Luau analyzer 0.740 passes for `src/types.luau`, `tests/test4.luau`, and `tests/test3.luau`. Focused negative probes reject `Object<number>`, invalid field narrowing, and unknown members. Existing tests `test.luau` and `test2.luau` still report pre-existing TypeErrors. StyLua is unavailable without an aftman.toml; `tests/test3.luau` user edits remain untouched.

## Follow-up / Risks

Function override subtyping and nominal parent-family identity remain outside this change. See `docs/limitations.md`.