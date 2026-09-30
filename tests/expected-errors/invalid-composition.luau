--!strict

-- Test: Invalid parent collisions and composition kinds
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Interface<T> = oop.Interface<T>
type Trait<T> = oop.Trait<T>
type Override<T> = oop.Override<T>
type Constructor<T> = oop.Constructor<T>
type Self = oop.Self
type Object = oop.Object
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

type MovementTrait = Trait<{ speed: number }>
type ServiceInterface = Interface<{ name: string }>
type Entity = Class<{ id: string }>
type NumberInterface = Interface<{
	collision: number,

	numberOnly: number,
}>

type StringInterface = Interface<{
	collision: string,

	stringOnly: string,
}>

type BooleanTrait = Trait<{
	collision: boolean,

	booleanOnly: boolean,
}>

type SuperCollisionSpec = {
	collision: {
		source: "super",
	},

	superOnly: number,
}

type SuperCollision = Class<SuperCollisionSpec>

-- Check: Trait Has No Object View
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidTraitObject = ObjectOf<MovementTrait>

-- Check: Interface Has No Object View
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidInterfaceObject = ObjectOf<ServiceInterface>

-- Check: Interface Has No Self View
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidInterfaceSelf = SelfOf<ServiceInterface>

-- Check: Interface Has No Class View
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidInterfaceClass = ClassOf<ServiceInterface>

-- Check: Interface Has No Impl View
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidInterfaceImpl = ImplOf<ServiceInterface>

-- Check: Parent Collision Without Override
-- Pass condition: this rejected access or assignment produces a type diagnostic.
type InvalidInterfaceCollision = Class<{}, NumberInterface, StringInterface>

type TestInvalidInterfaceCollision = ObjectOf<InvalidInterfaceCollision>

type InvalidTraitInterfaceCollision = Class<{}, BooleanTrait, NumberInterface>

type TestInvalidTraitInterfaceCollision = ObjectOf<InvalidTraitInterfaceCollision>

type InvalidSuperInterfaceCollision = Class<{}, SuperCollision, NumberInterface>

type TestInvalidSuperInterfaceCollision = ObjectOf<InvalidSuperInterfaceCollision>

type InvalidHiddenParentCollision = Class<{
	collision: "local",
}, NumberInterface, StringInterface>

type TestInvalidHiddenParentCollision = ObjectOf<InvalidHiddenParentCollision>

-- Check: Only One Super Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type OtherSuper = Class<{
	other: number,
}>

type InvalidTwoSupers = Class<{}, Entity, OtherSuper>

-- Check: Trait Cannot Construct Objects
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidTraitConstructor = Trait<{
	new: Constructor<() -> ()>,
}>

-- Check: Interface Cannot Construct Objects
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type InvalidInterfaceConstructor = Interface<{
	new: Constructor<() -> ()>,
}>
