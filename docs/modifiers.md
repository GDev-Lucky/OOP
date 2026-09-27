# Modifiers

Modifiers wrap a member type in a class, interface, or trait spec. They control independent aspects of that member.

## Visibility

```luau
OOP.Public<T>    -- default
OOP.Protected<T>
OOP.Private<T>
```

Public instance members appear in `ObjectOf<T>`. Protected and private instance members are available through `SelfOf<T>`. Public static members appear in `ClassOf<T>`.

## Static members

`Static<T>` moves a member from the instance surface to the class surface.

```luau
version: OOP.Static<string>,
format: OOP.Static<(number) -> string>,
```

Static function members are ordinary function values by default; no instance `self` is injected.

## Methods and function fields

Functions are methods by default. OOP injects `self` so callers use colon syntax.

```luau
run: (number) -> boolean,
callback: OOP.Field<(number) -> boolean>,
```

`run` is called as `object:run(1)`. `callback` is a stored function called as `object.callback(1)`. Use `Method<T>` to state the default explicitly.

## Assignment and mutability

`Const<T>` is the default: the member cannot be reassigned. `Var<T>` makes the member assignable.

```luau
name: OOP.Var<string>,
settings: OOP.Var<OOP.Immut<{ enabled: boolean }>>,
```

`Mut<T>` preserves normal table mutability. `Immut<T>` recursively removes writes from normal properties, nested tables, metatables, union/intersection components, and indexer read values. It is separate from `Const`/`Var`: the latter decides whether the property itself may be replaced.

## Constructors

`Constructor<T>` accepts a function type, makes the member static, and replaces its declared return with the final public object type.

```luau
new: OOP.Constructor<(string, number) -> ()>,
```

The public class view exposes `new(string, number) -> ObjectOf<...>`.

## Precedence

Nested modifiers are applied from the inside outward. The outer modifier wins when two modifiers control the same concern.

```luau
OOP.Public<OOP.Private<T>> -- public
OOP.Field<OOP.Method<F>>   -- field
OOP.Mut<OOP.Immut<Table>>  -- mutable
```

Use this deliberately; it makes composed modifier aliases predictable.