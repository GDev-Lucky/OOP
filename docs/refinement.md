# 5. Refinement

Sometimes you want a more specific type for an existing class without building another runtime class. `Refine<Base, Spec, Parents...>` gives you just that: a type-only overlay.

## Specialize a view

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Refine<B, S, P...> = OOP.Refine<B, S, P...>; type Constructor<T> = OOP.Constructor<T>; type Object = OOP.Object

type AnimalBase = Class<{
	name: string,
	new: Constructor<(string) -> ()>,
	getName: () -> string,
}>

type Animal<T = string> = Refine<AnimalBase, {
	name: T,
	new: (T) -> Object,
	getName: () -> T,
}>
```

The refined `Animal<"cat">` carries specialized views; it does **not** create a new constructor or runtime table. Your implementation still has to honor any promised refined return types. The compiler does not verify what a shared runtime implementation actually returns.

## References inside overrides

Bare `Object` in a refined override refers to the **current refined public object**. Members inherited unchanged from a `Class` keep their original base-object reference. Use `ObjectOf<AnimalBase>` if an override must explicitly return the base object. `Object` takes no generic arguments.

Refinement keeps the original member modifiers. Non-function replacements must be subtypes of the originals; function overrides must keep argument and return arity (including variadic tails), narrow corresponding types, and leave generic signatures unchanged.

## Refined parents

Extra parents can be added or replace a direct parent in the same bundle family. This changes the **type view**, not the runtime parent implementation. `:declare()` takes the base public view of a refined parent so the original runtime class can be passed unchanged. `BaseOf<T>` and `ToBase<T>` retrieve that base class view when you need it explicitly.

Refinement has important [family and runtime limitations](limitations.md#refinement-is-type-only). For every exported name, use the [API reference](api-reference.md).
