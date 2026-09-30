# Task: Organize type-checking tests

- Status: completed
- importance: 0.70
- confidence: 0.85
- createdAt: 2026-09-30T00:00:00Z
- lastUsedAt: 2026-09-30T00:00:00Z

## Description
Split large Luau type-checking scripts into focused, descriptively named positive and expected-error suites; leave the temporary `tests/test3.luau` unchanged.

## Context
The original `tests/test.luau` and `tests/test2.luau` mixed successful checks with expected diagnostics. `tests/test4.luau` and `tests/test5.luau` were untracked, focused refinement checks.

## Decisions
Place successful checks under `tests/positive/` and intentionally rejected checks under `tests/expected-errors/`. Preserve `--!strict`, short file and section descriptions, and stated pass conditions. The compiler emits readable/writable implementation members via `setproperty` in `src/types.luau`; `ImplOf` is not write-only.

## Likely Files
`tests/positive/`, `tests/expected-errors/`, and `tests/README.md`.

## Files Touched
Replaced `tests/test.luau` and `tests/test2.luau` with feature suites; reorganized the content of untracked `tests/test4.luau` and `tests/test5.luau`; added `tests/README.md`, `tests/positive/`, `tests/expected-errors/`, and this task record; updated `.ai/tasks/current.md`. Left `tests/test3.luau` untouched.

## Summary
Separated positive and expected-error checks, removed unused imports and fixtures, and moved supported indexed-entry writes and `ImplOf` reads to positive coverage. Retained manual negative refinement sketches in `tests/expected-errors/README.md` without treating them as active tests.

## Validation
StyLua `--syntax luau --check` passed for every new Luau suite except `tests/positive/function-refinements.luau`, whose existing variadic function-type syntax is not parsed by the available StyLua version. `git diff --check -- tests` passed. No Luau type analyzer was available locally; actual type-checking diagnostics remain unverified. `tests/test3.luau` had pre-existing working-tree changes and was not edited.

## Follow-up / Risks
Check `tests/positive/` for zero diagnostics and confirm intended diagnostics in `tests/expected-errors/` using Roblox Studio or a Luau analyzer with type-function support. In particular confirm each rejection when expanding `ObjectOf` in the new invalid-modifier checks.

## Correction (2026-09-30)
Removed the standalone `Immut` alias and its read from `tests/positive/function-refinements.luau`: `Immut` is a modifier processed on class members, not a standalone table transformer. Clarified the manual cycle example in `tests/expected-errors/README.md`. StyLua `--syntax luau --check` now passes on the corrected refinement suite; `git diff --check -- tests` passes. No Luau type analyzer was available for type-diagnostic validation.