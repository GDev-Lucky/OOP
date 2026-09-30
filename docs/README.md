# The OOP handbook

Start with [the README](../README.md) for the whole idea. Then follow the chapters:

1. [Getting started](getting-started.md) — write, build, and use a class.
2. [Core concepts](core-concepts.md) — specs, views, and self-references.
3. [Modifiers](modifiers.md) — who sees a member and whether it can change.
4. [Composition](composition.md) — parents, contracts, and collisions.
5. [Refinement](refinement.md) — specialize types without another runtime class.

## Looking for something specific?

| Question | Go to |
| --- | --- |
| How do I import runtime and types? | [Getting started: one import](getting-started.md#one-import) |
| Which type is my public instance? | [Core concepts: views](core-concepts.md#one-spec-several-views) |
| How do I declare a constructor? | [Modifiers: constructors](modifiers.md#constructors) |
| Why can't a caller see this member? | [Modifiers: visibility](modifiers.md#visibility) |
| How do parent conflicts resolve? | [Composition: collisions](composition.md#collisions) |
| What does `Object` mean inside `Refine`? | [Refinement: references](refinement.md#references-inside-overrides) |
| What does `:object()` check? | [Limitations: value checking](limitations.md#object-value-checking) |
| What is exported? | [API reference](api-reference.md) |

When something looks surprising, read [limitations and status](limitations.md) before relying on it in production.
