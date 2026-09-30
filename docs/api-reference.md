# API reference

This page is the lookup desk; read the [chapters](README.md) for the story. Require [`src/init.luau`](../src/init.luau) once: its type exports mirror [`src/types.luau`](../src/types.luau), and its runtime value is the builder.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Public<T> = OOP.Public<T>
```

The type aliases in examples are local shorthand, not separate imports. `OOP.Class` is available only as a type; the runtime value is `OOP` (aliased here to `Class`).

## Runtime builder

| Call | Result | Notes |
| --- | --- | --- |
| `Class.new<<T>>()` | Typed builder for class `T` | Creates a table with its own `__index`. |
| `builder:declare(parents...)` | Privileged implementation table | Copies non-`__index` parent entries. Later parents copied first; define local overrides afterward. |
| `builder:object(fields)` | Public object | Sets the instance metatable to the builder. `fields` supplies the instance values. |
| `builder:export()` | Public class table view | Returns the same runtime builder table with a narrower type. |

These operations do not install constructors, initialize inherited instance fields, implement interfaces automatically, or enforce visibility at runtime. See [getting started](getting-started.md) for a complete counter.

## Definitions

| Type | Purpose |
| --- | --- |
| `Class<Spec, Parents...>` | Compile a class from local members and optional parents. |
| `Interface<Spec>` | Compile a reusable type-only contract. |
| `Trait<Spec>` | Compile a reusable trait's metadata and views. |
| `Override<ClassType>` | Accept recorded collisions between composed parents. |
| `Refine<Base, Spec, Parents...>` | Specialize an existing class family at type level; no new runtime class. |

See [composition](composition.md) and [refinement](refinement.md).

## References

| Type | In a spec it means |
| --- | --- |
| `Object` | Public instance view; in a `Refine` override, the current refined object. |
| `Self` | Privileged instance view. |
| `ClassType` | Public class table view. |
| `Impl` | Privileged implementation view. |

These are reference types **inside specs**, not constructor functions. Inherited references in unchanged class members keep their base meaning under refinement; see [refinement](refinement.md#references-inside-overrides).

## Views and conversions

| Extract from a compiled class | Convert an existing compiled view | Result |
| --- | --- | --- |
| `ObjectOf<T>` | `ToObject<T>` | Public instance |
| `SelfOf<T>` | `ToSelf<T>` | Privileged instance |
| `ClassOf<T>` | `ToClass<T>` | Public class table |
| `ImplOf<T>` | `ToImpl<T>` | Implementation |
| `SpecOf<T>` | `ToSpec<T>` | Original local spec |
| `BaseOf<T>` | `ToBase<T>` | Base public class table for a refined family |

`ViewOf<T, K>` extracts a view by metadata key and `View<T, K>` converts to one. Prefer the named forms in user code. `ParentsOf<T, R, B = false>` produces the selected parent views; `B = true` selects base views. `:declare()` uses base parent views.

## Modifiers

| Concern | Exports | Default |
| --- | --- | --- |
| Visibility | `Public<T>`, `Protected<T>`, `Private<T>` | Public |
| Class versus instance | `Static<T>` | Instance |
| Function behavior | `Method<T>`, `Field<T>` | Method on instances; function on statics |
| Member replacement | `Const<T>`, `Var<T>` | Const |
| Nested table writes | `Mut<T>`, `Immut<T>` | Mut |
| Object-returning static factory | `Constructor<F>` | None |

The outermost modifier wins when modifiers address the same concern. More examples: [modifiers](modifiers.md).

## Object values

`ObjectValuesOf<T>` describes the instance field table accepted by `:object(fields)`. `AssertObjectValuesOf<T, V>` checks a *concrete field-table type* `V` for missing, incompatible, and unexpected fields. This extra exactness is not guaranteed by the generic `:object()` method; see [object value checking](limitations.md#object-value-checking).
