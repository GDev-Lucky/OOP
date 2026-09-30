# OOP

**A small runtime builder with a big type system for Luau.** Describe a class once, implement it with familiar `:` methods, and let type functions show the right members to the right people.

```luau
--!strict
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Var<T> = OOP.Var<T>; type Constructor<T> = OOP.Constructor<T>

type Counter = Class<{
	value: Var<number>,
	new: Constructor<(number) -> ()>,
	add: (number) -> number,
}>

local CounterImpl = Class.new<<Counter>>():declare()

function CounterImpl.new(start)
	return CounterImpl:object({ value = start })
end

function CounterImpl:add(amount)
	self.value += amount
	return self.value
end

local CounterClass = CounterImpl:export()
local counter = CounterClass.new(0)
print(counter:add(2)) -- 2
```

`Class<...>` describes types; `Class.new<<Counter>>()` builds the runtime class table. `OOP` is the single module you require for both. The local runtime alias `Class = OOP` keeps the syntax compact; `OOP.Class` is a **type export**, not a runtime constructor.

> **Status:** Experimental. The runtime builder supports `new`, `declare`, `object`, and `export`; the compiler handles visibility, composition, constructors, and views. The runtime is intentionally minimal: it does not automatically create instances, run constructors, or enforce types and visibility at runtime. See [limitations](docs/limitations.md).

## Find your way

Read the guides in order for a tour, or jump straight to what you need:

| If you want to… | Read |
| --- | --- |
| Make your first class and instance | [Getting started](docs/getting-started.md) |
| Understand specs, objects, and method `self` | [Core concepts](docs/core-concepts.md) |
| Control visibility, mutability, methods, and constructors | [Modifiers](docs/modifiers.md) |
| Inherit, use interfaces or traits, or resolve collisions | [Composition](docs/composition.md) |
| Specialize an existing class's types | [Refinement](docs/refinement.md) |
| Look up an export or a runtime method | [API reference](docs/api-reference.md) |
| Check guarantees and current caveats | [Limitations](docs/limitations.md) |

The [documentation index](docs/README.md) maps common questions to their answers.

## The shape of the library

- `src/init.luau` is the one-module entry point: runtime builder **and** re-exported type API.
- `src/types.luau` implements the type functions. You do not need to require it separately.
- `tests/positive/` and `tests/expected-errors/` contain type-checking examples, not runtime integration tests.

OOP uses Luau type functions, so try it with a Luau toolchain that supports them. Package installation and a release workflow are not documented yet; point `path.to.OOP` at your copy of `src/init.luau` using your project's module-path conventions.

Want to help? See [CONTRIBUTING.md](CONTRIBUTING.md). Licensed under [MIT](LICENSE).
