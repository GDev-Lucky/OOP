# 1. Getting started

A class has two sides: a **type spec** that tells Luau what exists, and a **runtime table** that gives those members behavior. Let's build a little counter.

## One import

Require `src/init.luau` using the path syntax of your project. It exposes the runtime builder and every public type from `src/types.luau`.

Our examples keep imports together in three lines: module, runtime aliases, and type aliases. Add only the aliases that example needs. `Class` can name both a local value and a local type in Luau.

```luau
--!strict
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Var<T> = OOP.Var<T>; type Constructor<T> = OOP.Constructor<T>
```

`Class.new` is a runtime method on `OOP`. The `Class<...>` alias is a compile-time type. There is no runtime `OOP.Class` value.

## Describe the class

```luau
type Counter = Class<{
	value: Var<number>,
	new: Constructor<(number) -> ()>,
	add: (number) -> number,
}>
```

`value` is writable because of `Var`. A function is a method by default, so `add` receives typed `self` automatically. `Constructor` declares a static function whose public return type is the object, regardless of the `()` written in its spec.

## Give it behavior

```luau
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

`Class.new<<Counter>>()` creates a builder. `:declare()` gives you its typed implementation table; `:object({...})` attaches that class as the instance metatable, so `:add` can be found through `__index`. `:export()` returns the public class view. The builder does **not** execute `new` for you: you define and call it yourself.

## What next?

[Core concepts](core-concepts.md) explains what each view sees. [Modifiers](modifiers.md) shows how to describe public, private, static, and immutable members; [composition](composition.md) shows how to share them. If you need a name quickly, use the [API reference](api-reference.md).
