# Type-checking tests

- `positive/` contains Luau files that should type-check without diagnostics.
- `expected-errors/` contains intentionally invalid type-checking cases. The pass condition is that the indicated checks produce diagnostics while their fixture declarations do not.

Check these files with Roblox Studio or a Luau analyzer using the project's type-function support. Do not run the expected-error files as part of a zero-diagnostic check. The `--!strict` header and the `Test`, `Result`, and `Pass condition` comments identify the expected outcome of each file; section-level checks state the expected outcome near the relevant statements.