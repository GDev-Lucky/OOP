# Getting started

## Current status

The implemented part of OOP is the compiler in `src/types.luau`. It exports types that Luau resolves at compile time. A runtime builder and usable package entry point are not implemented yet, so import `types.luau` directly while experimenting.

```luau
local OOP = require("path.to.types")

type Class<T, A...> = OOP.Class<T, A...>
type ObjectOf<T> = OOP.ObjectOf<T>
type ImplOf<T> = OOP.ImplOf<T>
type Var<T> = OOP.Var<T>
```

## Define a class

The first `Class` argument is a local member specification. Function members are methods by default; they receive an injected `self` parameter in compiled views. Properties are const by default.

```luau
type Score = Class<{
	value: Var<number>,
	add: (number) -> number,
}>

type ScoreObject = ObjectOf<Score>
type ScoreImpl = ImplOf<Score>
```

`ScoreObject` is the public instance surface. `ScoreImpl` is the privileged surface used by the future runtime and method implementations.

```luau
local impl: ScoreImpl = nil :: any

function impl:add(amount)
	self.value += amount
	return self.value
end
```

## Use the right view

- `ObjectOf<T>` is for callers of public instance APIs.
- `SelfOf<T>` is for methods that need public, protected, and private instance members.
- `ClassOf<T>` is for public static members and constructors.
- `ImplOf<T>` is for implementation code.
- `SpecOf<T>` recovers the original local specification.

Read [core concepts](core-concepts.md) for the view model, then [modifiers](modifiers.md) and [composition](composition.md) for the rest of the language.