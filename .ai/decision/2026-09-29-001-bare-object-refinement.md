# Bare object reference in refinements

- date: 2026-09-29
- status: accepted
- importance: 0.80
- confidence: 0.85
- createdAt: 2026-09-29T00:00:00Z
- lastUsedAt: 2026-09-29T00:00:00Z

`Object` is non-generic. A bare `Object` reference written in a `Refine` member override resolves to the current refined public view; references inherited from `Class` or its parents retain their base-object meaning. Explicit base returns in a refinement can use `ObjectOf<Base>`. The compiler tags overridden metadata entries so the resolver keeps these scopes distinct. Generic arguments to `Object` are rejected by Luau.

See `src/types.luau`, `tests/test4.luau`, and `docs/api-reference.md`. This supersedes the `Object<T>`/`Object<()>` reference semantics in `2026-09-29-type-only-refinement.md`; its other decisions remain in effect.