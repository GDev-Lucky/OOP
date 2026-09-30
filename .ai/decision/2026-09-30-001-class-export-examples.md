# Single-local class export examples

- date: 2026-09-30
- status: accepted
- importance: 0.70
- confidence: 1.0
- createdAt: 2026-09-30T00:00:00Z
- lastUsedAt: 2026-09-30T00:00:00Z

In public module examples, use one runtime local for a class's implementation: `local Name = Class.new<<Name>>():declare()`, define its methods, then `return Name:export()`. Avoid extra `*Impl` and `*Class` locals for the same class. Show consumers in a separate module snippet. For inline inheritance examples, pass `Parent:export()` as the parent view. Confirmed by the user and consistent with `src/init.luau` (`export` returns the same runtime table with a public class type).