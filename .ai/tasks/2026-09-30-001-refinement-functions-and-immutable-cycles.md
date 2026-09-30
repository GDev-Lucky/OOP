# Task: Validate refinement functions and immutable indexer cycles

- Status: completed
- importance: 0.80
- confidence: 0.65
- createdAt: 2026-09-30T00:00:00Z
- lastUsedAt: 2026-09-30T00:00:00Z

## Description
Complete the partial function override check and avoid recursion in immutable indexed tables.

## Context
`src/types.luau`, `tests/test4.luau`, `tests/test5.luau`.

## Decisions
Preserve specialized/narrowed function argument semantics; require matching fixed arity, variadic shape, and narrowed return types. Disallow altered generic signatures until safe remapping is supported. Do not change runtime validation or structural family matching.

## Likely Files
`src/types.luau`, `tests/test5.luau`, `docs/limitations.md`.

## Files Touched
`src/types.luau`, `tests/test5.luau`, `docs/limitations.md`, `.ai/tasks/current.md`, and this record.

## Summary
Corrected function return comparison to inspect function return packs, checked fixed and variadic shape and generic restrictions. Cache immutable indexed tables before walking their indexers and use the same placeholder technique in view resolution.

## Validation
`git diff --check` passed for edited tracked source and documentation. No Luau analyzer executable was found locally, so type-level regression tests were not run; negative cases are documented in `tests/test5.luau` for manual analyzer expansion.

## Follow-up / Risks
Run analyzer over `src/types.luau`, `src/init.luau`, `tests/test4.luau`, and `tests/test5.luau` using the project's Luau version. New generic function overrides remain intentionally conservative; type-function reification of recursive indexers needs analyzer verification.

## Correction (2026-09-30)
The attempted placeholder-indexer fix called unsupported `setreadindexer`/`setwriteindexer` methods. Restored `types.newtable` with separate indexer read/write results, added an active-cycle guard in `MakeImmutable`, and kept the class resolver's explicit recursive-indexer error. Updated `tests/test5.luau` and `docs/limitations.md`; recursive indexed tables remain unsupported but no longer recurse indefinitely in the immutable transformer. Analyzer validation remains pending.