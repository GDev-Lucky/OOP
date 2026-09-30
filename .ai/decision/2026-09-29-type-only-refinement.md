# Type-only class refinement

- date: 2026-09-29
- status: accepted
- importance: 0.80
- confidence: 0.80
- createdAt: 2026-09-29T00:00:00Z
- lastUsedAt: 2026-09-29T00:00:00Z

Luau alias parameters instantiate `Refine<Base, Spec, Parents...>` as a type-only overlay; they do not create additional runtime implementations. `Class` defines the base spec. Refine retains member modifiers and adds local overrides and effective parents before rebuilding the class views. Refine parents take precedence over direct base parents when recorded families compare equal. `Object<()>` refers to the base object; `Object<T>` is an opt-in reference to the current refined object. The compiler validates only properties observable after alias instantiation; generic source spelling and runtime behavior are developer responsibilities.

See `src/types.luau`, `tests/test4.luau`, and `docs/limitations.md` for implementation and limits.