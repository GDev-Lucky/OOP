# Task: Simplify class export examples

- Status: completed
- importance: 0.65
- confidence: 1.0
- createdAt: 2026-09-30T00:00:00Z
- lastUsedAt: 2026-09-30T00:00:00Z

## Description
Show the intended single-local class implementation and module export syntax in public documentation.

## Context
Examples used separate `*Impl` and `*Class` runtime locals, making basic classes appear unnecessarily verbose.

## Decisions
Use `local Name = Class.new<<Name>>():declare()`, define members on `Name`, and finish module examples with `return Name:export()`. Put caller examples in separate code blocks. Parent classes may be exported inline when composed in the same example.

## Likely Files
`README.md`, `docs/getting-started.md`, `docs/core-concepts.md`, `docs/modifiers.md`, `docs/composition.md`.

## Files Touched
`README.md`, `docs/getting-started.md`, `docs/core-concepts.md`, `docs/modifiers.md`, `docs/composition.md`, `.ai/tasks/current.md`, this record, `.ai/decision/latest.md`, `.ai/decision/2026-09-30-001-class-export-examples.md`.

## Summary
Updated class implementation examples to use one runtime local and a module return; separated module callers from implementations.

## Validation
Workflow validation passed (23 Markdown files, 14 memory units); edited documentation has balanced fences and working relative Markdown links; `git diff --check` passed and new memory files have no trailing whitespace. No Luau analyzer installed, so snippets were not type-checked or executed.

## Follow-up / Risks
Documentation snippets are not covered by an automated Luau integration test; run them in a compatible Luau/Roblox toolchain when available.