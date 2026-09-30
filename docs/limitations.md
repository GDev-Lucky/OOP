# Limitations and status

OOP is experimental. The type compiler is extensive; the runtime builder is deliberately small. [Getting started](getting-started.md) shows the implemented path, not a promise of a full runtime framework.

## Runtime is minimal

`src/init.luau` is the single entry point, but it does **not** automatically execute a constructor, initialize inherited instance fields, apply runtime visibility, or perform runtime type checks. `:declare()` copies values from parents (not a live inheritance chain). `:object(fields)` sets a metatable on the supplied field table. Interfaces are type-only; traits require actual implementation tables for runtime behavior. Tests under `tests/` primarily exercise type checking, not runtime execution.

## Object value checking

`:object(value)` checks required fields and their types statically, but cannot reliably reject extra fields because Luau permits table width subtyping. `AssertObjectValuesOf<T, V>` rejects unexpected keys when `V` is a concrete field-table type; `any` and dynamically filled tables do not provide the same guarantee.

## Refinement is type-only

`Refine<Base, Spec, Parents...>` changes types without creating a new runtime class. It preserves member modifiers and replaces direct parents whose bundle families compare equal, but cannot prove the shared runtime implementation satisfies narrower results. Non-function replacements must be subtypes; function overrides preserve argument and return arity (including variadic tails), narrow corresponding types, and keep generic signatures unchanged. `Object` in an override refers to the refined object; unchanged inherited members keep base-object references. Use `ObjectOf<Base>` for an explicit base return. `Object` is not generic.

Independently declared but structurally equal class bundles can compare as one family, so replacement is not a nominal-identity guarantee. Avoid composing such independently declared parents. `declare` accepts base class views even for refined parents; this does not specialize their constructors at runtime.

## Immutable indexers

`Immut<T>` makes indexed *read values* deeply immutable, but Luau may still allow replacing an indexed entry itself:

```luau
array[1].score = 10 -- intended to be rejected
array[1] = replacement -- may still type-check
```

The same caveat applies to dictionary entries. Recursive indexed tables are not supported by `Immut<T>` or the class resolver: they report a type-function error rather than recurse indefinitely.

## Toolchain and metadata

The view compiler uses hidden metadata embedded in types. Do not depend on its representation; use exported extractors and conversions. Luau type-function support varies by toolchain and version. Check examples with the same toolchain you use for your project, and do not assume these types enforce behavior at runtime.
