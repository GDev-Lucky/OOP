# Core concepts

## A spec compiles into views

`Class<T, A...>` accepts a member spec and optional composition sources. Rather than exposing one broad table type, OOP creates context-specific views:

| View | Purpose |
| --- | --- |
| `ObjectOf<T>` | Public instance API |
| `SelfOf<T>` | Privileged instance API for methods |
| `ClassOf<T>` | Public static API and constructors |
| `ImplOf<T>` | Privileged implementation/runtime API |
| `SpecOf<T>` | Original local class specification |

`ObjectOf<T>` is intentionally narrow: it excludes protected, private, and static members. `ImplOf<T>` is deliberately broader and writable so implementation code can define methods and static values.

## Late-bound references

Use symbolic references in a spec when a member should refer to the final compiled class:

```luau
type Node = Class<{
	parent: OOP.Var<OOP.Object?>,
	clone: () -> OOP.Object,
	getSelf: () -> OOP.Self,
}>
```

The available references are `Self`, `Object`, `ClassType`, and `Impl`. OOP resolves them after it builds the final class views. This means an interface, trait, or superclass can describe `Object` without becoming tied to the original source type when composed into a derived class.

## Recovering a view

Use `ToObject<T>`, `ToSelf<T>`, `ToClass<T>`, `ToImpl<T>`, or `ToSpec<T>` to convert a known compiled view. The equivalent `*Of` types extract a view from a compiled class bundle.

```luau
type PublicNode = OOP.ObjectOf<Node>
type ClassAgain = OOP.ToClass<PublicNode>
```

The compiler carries hidden metadata with generated views to preserve this identity through conversions. That representation is an implementation detail; depend on the exported conversion types instead.

## Interfaces and traits

`Interface<T>` defines a reusable contract. `Trait<T>` defines reusable member composition with its own compiled privileged views. Both can be composed into a class. See [composition](composition.md).