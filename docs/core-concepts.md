# 2. Core concepts

A spec is not an object factory. It is a map of members that Luau compiles into several useful views. The small runtime builder then lets you implement that map.

## One spec, several views

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Private<T> = OOP.Private<T>; type Var<T> = OOP.Var<T>

type Lamp = Class<{
	isOn: Var<boolean>,
	secretCode: Private<string>,
	toggle: () -> boolean,
}>

local LampImpl = Class.new<<Lamp>>():declare()
function LampImpl:toggle()
	self.isOn = not self.isOn
	return self.isOn
end
```

| View | Who uses it | What it exposes |
| --- | --- | --- |
| `ObjectOf<T>` | Callers | Public instance members |
| `SelfOf<T>` | Method bodies | Public, protected, and private instance members |
| `ClassOf<T>` | Callers of the class table | Public statics and constructors |
| `ImplOf<T>` | Implementation | Writable method and static definitions, plus builder methods |
| `SpecOf<T>` | Type-level inspection | The original local specification |

`Class<...>` itself has the public object as its primary type view; the named extractors help when you want to be explicit. Access restrictions here are **type-system** views, not runtime security. Luau does not hide table keys at runtime.

## References to this class

When a spec needs to talk about itself, use a reference rather than naming the class recursively:

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Object = OOP.Object; type Var<T> = OOP.Var<T>

type Node = Class<{
	parent: Var<Object?>,
	clone: () -> Object,
}>
```

`Object` resolves to the public instance view. `Self`, `ClassType`, and `Impl` similarly refer to the privileged instance, public class table, and implementation views. Composition can rebind these references to a derived class; [refinement](refinement.md#references-inside-overrides) has an important exception for inherited references.

## Recover another view

`ObjectOf<T>` extracts a view from a compiled class; `ToObject<T>` converts a known compiled view to that view. For example, `ToClass<ObjectOf<Node>>` gets the public class table type back. Keep the compiler's hidden metadata opaque; use the exported helpers instead.

Next: [modifiers](modifiers.md) give each member its own rules. For a complete list of view helpers, see the [API reference](api-reference.md#views-and-conversions).
