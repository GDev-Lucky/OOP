# Composition

## Sources

The remaining arguments to `Class<T, A...>` are composition sources:

```luau
type Player = OOP.Class<
	{ name: OOP.Var<string> },
	Entity,
	Serializable,
	Movable
>
```

A class can include one superclass, plus any number of interfaces and traits. Composition sources must be previously compiled `Class`, `Interface`, or `Trait` types.

## Inheritance rules

- Public and protected inherited members participate in composition.
- Private members are not inherited into another class's metadata.
- Inherited metadata is merged before the local spec.
- Local members therefore define the resulting member type when there is no unresolved parent collision.
- `Self`, `Object`, `ClassType`, and `Impl` references resolve against the final composed class.

## Collisions require `Override`

If two composed sources define the same non-private member, the class has an unresolved collision. Defining the same member locally does not clear that invalid parent composition.

```luau
type First = OOP.Interface<{ id: string }>
type Second = OOP.Interface<{ id: number }>

type Result = OOP.Override<OOP.Class<{}, First, Second>>
```

`Override<T>` explicitly accepts the collision. Source order chooses the inherited definition: the first source has priority. `Override` applies only to `Class<...>`, not standalone interfaces or traits.

## Interface versus trait

Interfaces are reusable contracts. Traits are reusable member composition that also has compiled `Self`, `Class`, and `Impl` views. Both participate in the same merging and collision rules when included in a class.