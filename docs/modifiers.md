# 3. Modifiers

A plain property is public and const; a plain function is a method. Modifiers change only the parts you name, keeping the spec pleasantly small.

## Visibility

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Public<T> = OOP.Public<T>; type Protected<T> = OOP.Protected<T>; type Private<T> = OOP.Private<T>

type Door = Class<{
	label: Public<string>, -- Public is optional here
	unlock: Protected<(string) -> boolean>,
	pin: Private<string>,
}>
```

Callers see `label`, not `unlock` or `pin`. Method `self` can see all three. Visibility is enforced by the type views, not by runtime table access.

## Properties and assignment

A const member cannot be reassigned through the public view. `Var<T>` allows replacement; `Mut<T>` and `Immut<T>` govern *inside* a table, independently of that outer assignment rule.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Var<T> = OOP.Var<T>; type Immut<T> = OOP.Immut<T>

type Settings = Class<{
	name: Var<string>,
	options: Immut<{ sound: { enabled: boolean } }>,
}>
```

`Const<T>` and `Mut<T>` spell out the defaults when you need them. `Immut<T>` recursively removes writes through ordinary nested table properties, including indexed read values. [Indexer writes have a caveat](limitations.md#immutable-indexers).

## Methods or stored functions?

Function members are methods by default: the compiler injects `self`, and callers write `object:run()`. `Field<F>` keeps an ordinary function value, called as `object.callback()` without an injected instance argument. `Method<F>` states the default explicitly.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Field<T> = OOP.Field<T>

type Worker = Class<{
	run: (number) -> boolean,
	callback: Field<(number) -> boolean>,
}>
```

## Static members

`Static<T>` puts a member on the class table instead of an instance. Static functions are ordinary functions by default: no instance `self` is injected.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Static<T> = OOP.Static<T>

type Clock = Class<{
	version: Static<string>,
	format: Static<(number) -> string>,
}>
```

## Constructors

`Constructor<F>` marks a function static and gives its public class view the public object return type. The written return in the spec is replaced; `()` makes the intent clear. You still have to implement and call the runtime function yourself.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Constructor<T> = OOP.Constructor<T>

type Badge = Class<{
	name: string,
	new: Constructor<(string) -> ()>,
}>

local BadgeImpl = Class.new<<Badge>>():declare()
function BadgeImpl.new(name)
	return BadgeImpl:object({ name = name })
end
local BadgeClass = BadgeImpl:export()
local badge = BadgeClass.new("Explorer")
```

## Nesting rules

Nested modifiers apply inside out: the **outer** modifier wins when both address the same concern. Thus `Public<Private<string>>` is public, and `Field<Method<(number) -> number>>` is a field. Prefer one modifier per concern whenever possible.

Next: [composition](composition.md), or jump to the [modifier index](api-reference.md#modifiers).
