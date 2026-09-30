# 4. Composition

Once a class stands on its own, it can reuse another class's members or promise to satisfy an interface. The type compiler merges the specs; the runtime builder copies members from runtime parents passed to `:declare()`.

## Parents

`Class<Spec, Parents...>` accepts at most one superclass and any number of interfaces and traits. Public and protected members compose; private members do not become inherited metadata. A local member can replace an inherited member unless the parents conflict with one another.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Interface<T> = OOP.Interface<T>; type Constructor<T> = OOP.Constructor<T>

type Named = Interface<{ getName: () -> string }>
type Entity = Class<{ id: string }>
type Player = Class<{
	name: string,
	new: Constructor<(string, string) -> ()>,
	getName: () -> string,
}, Entity, Named>

local EntityImpl = Class.new<<Entity>>():declare()
local EntityClass = EntityImpl:export()
local PlayerImpl = Class.new<<Player>>():declare(EntityClass)

function PlayerImpl.new(id, name)
	return PlayerImpl:object({ id = id, name = name })
end
function PlayerImpl:getName()
	return self.name
end

local PlayerClass = PlayerImpl:export()
local player = PlayerClass.new("1", "Ada")
```

`Named` is a type-only contract: there is no runtime interface argument to pass to `:declare()`. For runtime reuse, pass actual parent class/trait tables in the same parent order as the spec. `declare` copies non-`__index` keys, processing later parents first so the first parent wins; define local overrides *after* calling `:declare()`. It is **not** a dynamic superclass link: changes to a parent after declaration are not automatically inherited.

## Traits

`Trait<Spec>` defines reusable members with compiled privileged views; unlike an interface, a trait can contribute runtime behavior when you supply its implementation to `:declare()`. Neither a trait nor an interface creates objects on its own. See [views](core-concepts.md#one-spec-several-views) for the type-side distinction.

## Collisions

Two parents with the same non-private member cause a type-level collision, even if the child declares that member locally. Explicitly acknowledge it with `Override<...>`; the first source has priority for inherited definitions.

```luau
local OOP = require(path.to.OOP)
local Class = OOP
type Class<T, A...> = OOP.Class<T, A...>; type Interface<T> = OOP.Interface<T>; type Override<T> = OOP.Override<T>

type First = Interface<{ id: string }>
type Second = Interface<{ id: number }>
type Chosen = Override<Class<{}, First, Second>>
```

Use `Override` only on a class, not an interface or standalone trait. The runtime copies parent values according to `:declare()`'s order; interfaces contribute no runtime values. This is an explicit choice, not an automatic conflict solver.

Want a different type view of the *same* runtime class? Continue to [refinement](refinement.md).
