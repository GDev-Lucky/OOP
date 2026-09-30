# Task: Add type-only class refinement

- Status: completed
- importance: 0.80
- confidence: 0.70
- createdAt: 2026-09-29T00:00:00Z
- lastUsedAt: 2026-09-29T00:00:00Z

## Description

Add type-only Refine<Base, Spec, Parents...> with Object<()> base and Object<T> refined references, metadata-preserving member overrides, and parent-family replacement.

## Context

Existing Class metadata, parent pack, and view builder live in `src/types.luau`. Existing edit to `tests/test3.luau` belongs to the user and must be preserved.

## Decisions

Generic instantiations are type-only; one runtime implementation. Refined parent wins over base parent when their bundle families compare equal. Non-function overrides must narrow the original member; function overrides retain modifiers but are not subtype-checked.

## Likely Files

`src/types.luau`, `tests/test4.luau`.

## Files Touched

`src/types.luau`, `tests/test4.luau`, `docs/api-reference.md`, `docs/limitations.md`, `.ai/tasks/current.md`, `.ai/decision/latest.md`, `.ai/decision/2026-09-29-type-only-refinement.md`, and this record.

## Summary

Implemented `Refine<Base, Spec, Parents...>`, `Object<()>` and `Object<T>` marker handling, family-based parent replacement, and dedicated type tests.

## Validation

Luau analyzer 0.740 passes for `src/types.luau` and `tests/test4.luau`. Forced negative checks reject a non-subtype member, an unknown override, and generic object references in `Class`. Baseline `tests/test.luau` and `tests/test2.luau` include pre-existing intentional TypeErrors. StyLua is unavailable without aftman.toml.

## Follow-up / Risks

Generic argument identity in `Object<T>` is not verified, function overrides are not subtype-checked, and independently declared structurally equal bundles can collide as one family. The runtime implementation is unfinished; this feature is type-only. Existing edit to `tests/test3.luau` left untouched.