# Task: Rewrite documentation and unify exports

- Status: completed
- importance: 0.75
- confidence: 0.85
- createdAt: 2026-09-30T00:00:00Z
- lastUsedAt: 2026-09-30T00:00:00Z

## Description
Rewrite the public documentation as a guided handbook with a searchable reference, use compact local type aliases, and expose all public types from the runtime entry point.

## Context
The previous README and guides described an unusable entry point despite an existing small runtime builder; the type API lived in `src/types.luau`.

## Decisions
Keep a single `src/init.luau` require for public runtime and type use. Distinguish type compilation from runtime guarantees. Keep examples small with three import/alias lines and link guides to a quick-reference index.

## Likely Files
`README.md`, `docs/`, `src/init.luau`.

## Files Touched
`README.md`, all existing `docs/*.md`, new `docs/refinement.md`, `src/init.luau`, `.ai/tasks/current.md`, this record.

## Summary
Re-exported all `src/types.luau` public types through `src/init.luau`, fixed an undefined runtime object annotation, rewrote the README and handbook, and added a refinement chapter.

## Validation
Export parity and Markdown relative links checked; `git diff --check` and workflow validation performed. No Luau analyzer installed. StyLua shim unavailable without aftman.toml.

## Follow-up / Risks
Verify end-to-end type diagnostics and runtime behavior in a compatible Luau/Roblox toolchain; documentation examples are not integrated into the test harness.
