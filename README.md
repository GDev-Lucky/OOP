# OOP

> An experimental compile-time OOP framework for Luau type functions.

OOP compiles a declarative class specification into strongly typed views for public instances, privileged method bodies, public class members, and runtime implementation. Its purpose is better autocomplete and type checking without making the runtime model responsible for the type system.

## Status

**Early development.** The type compiler in [`src/types.luau`](src/types.luau) is the active implementation. The runtime is intentionally small and not implemented yet; [`src/init.luau`](src/init.luau) is not a usable package entry point. Treat the project as experimental until a runtime API, packaging, and release process are in place.

## What it provides

- Class, interface, and trait composition
- Public, protected, and private member views
- Static and instance members
- Method self injection and ordinary function fields
- Const/var member assignment rules
- Structural deep immutability for table properties
- Typed constructors
- Late-bound `Self`, `Object`, `ClassType`, and `Impl` references
- Explicit handling of inherited-member collisions
- Conversion between compiled views

## Example

For now, import the type compiler directly:

```luau
--!strict

local OOP = require("path.to.types")

type Class<T, A...> = OOP.Class<T, A...>
type ObjectOf<T> = OOP.ObjectOf<T>
type SelfOf<T> = OOP.SelfOf<T>
type ImplOf<T> = OOP.ImplOf<T>
type Var<T> = OOP.Var<T>
type Constructor<T> = OOP.Constructor<T>

type Counter = Class<{
	value: Var<number>,
	increment: (number) -> number,
	new: Constructor<(number) -> ()>,
}>

type CounterObject = ObjectOf<Counter>
type CounterSelf = SelfOf<Counter>
type CounterImpl = ImplOf<Counter>

local impl: CounterImpl = nil :: any

function impl:increment(amount)
	local self: CounterSelf = self
	self.value += amount
	return self.value
end

local object: CounterObject = nil :: any
object:increment(1)
```

The example demonstrates the compiler surface only. It does not construct an object at runtime.

## Documentation

- [Getting started](docs/getting-started.md)
- [Core concepts](docs/core-concepts.md)
- [Modifiers](docs/modifiers.md)
- [Composition](docs/composition.md)
- [API reference](docs/api-reference.md)
- [Limitations and status](docs/limitations.md)

## Project layout

```text
src/types.luau  Type-function compiler and exported type API
src/init.luau   Future package/runtime entry point (unfinished)
tests/          Luau type-checking examples and coverage
docs/           User documentation
```

## Contributing

Contributions are welcome, especially focused compiler tests, documentation corrections, and small type-system improvements. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

Distributed under the [MIT License](LICENSE).