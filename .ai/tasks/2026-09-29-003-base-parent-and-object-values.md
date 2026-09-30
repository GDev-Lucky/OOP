# Task: Base-parent declaration and object value validation

- Status: completed
- importance: 0.80
- confidence: 0.90
- createdAt: 2026-09-29T00:00:00Z
- lastUsedAt: 2026-09-29T00:00:00Z

## Description

Allow `declare` to take the original public class view of refined parents; expose base view conversion; tighten concrete object-field checks without adding runtime inheritance helpers.

## Context

See `src/types.luau`, `src/init.luau`, `tests/test3.luau`, `tests/test4.luau`, and `docs/api-reference.md`.

## Decisions

Keep `:object`'s existing field-table signature: a generic exact-value type-function signature prevents refined `declare` from resolving in Luau 0.740. Select original class-family views only for runtime `declare` arguments; preserve specialized parent metadata in `Class`.

## Likely Files

`src/types.luau`, `src/init.luau`, `tests/test4.luau`, `docs/api-reference.md`, `docs/limitations.md`.

## Files Touched

`src/types.luau`, `src/init.luau`, `tests/test4.luau`, `docs/api-reference.md`, `docs/limitations.md`, `.ai/tasks/current.md`, and this task record.

## Summary

`BaseOf` and `ToBase` select the original class family view. `ParentsOf<T, R, B>` defaults to refined views and selects original class views with `B = true`; runtime `declare` uses the base option. `AssertObjectValuesOf<T, V>` rejects unexpected keys for concrete field table types. `:object` retains the existing required-field signature because Luau's generic type-function expansion cannot currently enforce extra keys inside the declaration method. No `super` helper was added.

## Validation

Luau analyzer 0.740 passes for `src/types.luau`, `src/init.luau`, and `tests/test4.luau`. A focused concrete invalid-field probe rejects an unexpected field. Existing user-owned `tests/test3.luau` still reports its pre-existing unknown global `object` on line 62; its `declare(Animal)` call now passes. StyLua check shows existing formatting differences; no unrelated files were reformatted.

## Follow-up / Risks

The type of `:object` cannot reject extra fields without a usable exact-value generic signature; validate concrete fields with `AssertObjectValuesOf<T, V>` when necessary. The original class family's constructor remains unspecialized at runtime. `git diff --check` reports pre-existing trailing whitespace in the user-owned `tests/test3.luau`.