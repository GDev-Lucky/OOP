# API reference

All exported APIs currently come from [`src/types.luau`](../src/types.luau).

## Definitions

| Type | Description |
| --- | --- |
| `Class<T, A...>` | Compiles a class spec `T` with optional composition sources `A...`. |
| `Interface<T>` | Compiles a reusable interface specification. |
| `Trait<T>` | Compiles reusable trait metadata and privileged views. |
| `Override<T>` | Resolves a class's recorded composition collisions. |

## References

| Type | Resolves to |
| --- | --- |
| `Self` | Final privileged instance view. |
| `Object` | Final public object view. |
| `ClassType` | Final public class view. |
| `Impl` | Final privileged implementation view. |

## View extraction and conversion

| Extractor | Converter |
| --- | --- |
| `ObjectOf<T>` | `ToObject<T>` |
| `SelfOf<T>` | `ToSelf<T>` |
| `ClassOf<T>` | `ToClass<T>` |
| `ImplOf<T>` | `ToImpl<T>` |
| `SpecOf<T>` | `ToSpec<T>` |

`ViewOf<T, K>` extracts a metadata view by key, and `View<T, K>` converts to one. Prefer the named helpers in public code.

## Modifiers

| Category | Types |
| --- | --- |
| Visibility | `Public<T>`, `Protected<T>`, `Private<T>` |
| Placement | `Static<T>` |
| Function behavior | `Method<T>`, `Field<T>` |
| Reassignment | `Const<T>`, `Var<T>` |
| Deep table mutability | `Mut<T>`, `Immut<T>` |
| Construction | `Constructor<T>` |

See [modifiers](modifiers.md) for their semantics and nesting precedence.