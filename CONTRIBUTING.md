# Contributing

Thanks for helping improve OOP.

## Before you start

- The project is experimental and currently centered on Luau type functions.
- Keep changes narrow. Do not add runtime architecture or dependencies unless the issue or discussion establishes the need.
- Read the relevant tests in [`tests/`](tests/) before changing compiler behavior.

## Pull requests

1. Explain the behavior being changed and why.
2. Add or update a focused Luau type-checking example when changing the compiler.
3. Keep public documentation aligned with behavior implemented in `src/types.luau`.
4. Format edited Luau files with StyLua when applicable.
5. Do not include generated files, editor settings, or unrelated refactors.

## Issues

Please include a small reproducible Luau example, the expected type behavior, the observed behavior, and the Luau tooling/version you used.

## Design direction

The framework keeps type compilation separate from runtime construction. Preserve that separation unless a deliberate project decision changes it.