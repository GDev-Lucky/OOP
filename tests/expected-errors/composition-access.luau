--!strict

-- Test: Visibility, static access, and inherited immutability
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.
-- Note: The allowed callback call is tested in positive/member-overrides.luau.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Interface<T> = oop.Interface<T>
type Trait<T> = oop.Trait<T>
type Override<T> = oop.Override<T>
type Public<T> = oop.Public<T>
type Protected<T> = oop.Protected<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Method<T> = oop.Method<T>
type Field<T> = oop.Field<T>
type Var<T> = oop.Var<T>
type Mut<T> = oop.Mut<T>
type Immut<T> = oop.Immut<T>
type Constructor<T> = oop.Constructor<T>
type Self = oop.Self
type Object = oop.Object
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>

type ServiceInterface = Interface<{
	name: Var<string>,

	execute: (number) -> string,

	parse: Field<(string) -> number>,

	version: Static<string>,

	formatVersion: Static<(number) -> string>,

	protectedState: Protected<Var<number>>,

	protectedMethod: Protected<(number) -> number>,

	privateState: Private<Var<boolean>>,

	privateMethod: Private<() -> boolean>,
}>

type ReferenceInterface = Interface<{
	parent: Var<Object?>,
	clone: () -> Object,
	nested: { owner: Object },
}>
type SettingsInterface = Interface<{
	settings: Immut<{
		enabled: boolean,

		nested: {
			value: number,
		},
	}>,
}>
type Service = Class<{ serviceOnly: string }, ServiceInterface, ReferenceInterface, SettingsInterface>
local serviceObject: ObjectOf<Service> = nil :: any
local serviceSelf: SelfOf<Service> = nil :: any
type MovementTrait = Trait<{
	speed: Var<number>,

	move: (number) -> number,

	transform: Field<(number) -> string>,

	category: Static<string>,

	protectedMultiplier: Protected<Var<number>>,

	protectedMove: Protected<(number) -> number>,

	privateCounter: Private<Var<number>>,

	privateMove: Private<(number) -> number>,
}>
type Movable = Class<{ label: string }, MovementTrait>
local movableObject: ObjectOf<Movable> = nil :: any
local movableSelf: SelfOf<Movable> = nil :: any
type EntitySpec = {
	new: Constructor<(string) -> ()>,

	id: Var<string>,

	enabled: Var<boolean>,

	clone: () -> Object,

	parent: Var<Object?>,

	getSelf: Protected<() -> Self>,

	protectedValue: Protected<Var<number>>,

	protectedMethod: Protected<(string) -> string>,

	privateValue: Private<Var<string>>,

	privateMethod: Private<() -> string>,

	kind: Static<string>,

	create: Static<(string) -> Object>,
}

type Entity = Class<EntitySpec>
type Player = Class<{ username: string }, Entity>
local playerObject: ObjectOf<Player> = nil :: any
local playerSelf: SelfOf<Player> = nil :: any
type ParentPrioritySpec = {
	value: number,

	run: (number) -> number,

	callback: Field<(number) -> string>,

	state: Immut<{
		value: number,
	}>,
}

type ParentPriority = Class<ParentPrioritySpec>

type ChildPrioritySpec = {
	value: Var<string>,

	run: Field<(string) -> boolean>,

	callback: Method<(string) -> number>,

	state: Mut<{
		value: number,
	}>,
}

type ChildPriority = Class<ChildPrioritySpec, ParentPriority>
local priorityObject: ObjectOf<ChildPriority> = nil :: any
type VisibilityParentSpec = {
	publicToPrivate: Var<number>,

	publicToProtected: Var<number>,

	protectedToPublic: Protected<Var<number>>,

	protectedToPrivate: Protected<Var<number>>,

	publicMethodToProtected: (number) -> number,

	protectedMethodToPublic: Protected<(number) -> number>,
}

type VisibilityParent = Class<VisibilityParentSpec>

type VisibilityChildSpec = {
	publicToPrivate: Private<Var<string>>,

	publicToProtected: Protected<Var<string>>,

	protectedToPublic: Public<Var<string>>,

	protectedToPrivate: Private<Var<string>>,

	publicMethodToProtected: Protected<(string) -> string>,

	protectedMethodToPublic: Public<(string) -> string>,
}

type VisibilityChild = Class<VisibilityChildSpec, VisibilityParent>
type VisibilityGrandchild = Class<{ grandchildOnly: boolean }, VisibilityChild>
local visibilityObject: ObjectOf<VisibilityChild> = nil :: any
local grandchildObject: ObjectOf<VisibilityGrandchild> = nil :: any
local grandchildSelf: SelfOf<VisibilityGrandchild> = nil :: any
type HealthInterface = Interface<{
	health: Var<number>,
	heal: (number) -> number,
}>

type NameInterface = Interface<{
	displayName: Var<string>,
	getDisplayName: () -> string,
}>

type SerializeInterface = Interface<{
	serialize: () -> string,
}>

type PositionTrait = Trait<{
	x: Var<number>,
	y: Var<number>,

	moveTo: (number, number) -> (),
}>

type DebugTrait = Trait<{
	debugName: Var<string>,

	debug: () -> string,

	protectedDebugId: Protected<Var<number>>,
}>

type ActorBaseSpec = {
	actorId: Var<number>,

	getActorId: () -> number,
}

type ActorBase = Class<ActorBaseSpec>
type ComplexActorSpec = {
	active: Var<boolean>,
}

type ComplexActor = Class<
	ComplexActorSpec,
	PositionTrait,
	HealthInterface,
	DebugTrait,
	NameInterface,
	ActorBase,
	SerializeInterface
>

local actorObject: ObjectOf<ComplexActor> = nil :: any

-- Check: Interface Protected On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _interfaceProtectedObject = serviceObject.protectedState

local _interfaceProtectedMethodObject = serviceObject:protectedMethod(1)

-- Check: Interface Private Not Inherited
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _interfacePrivateObject = serviceObject.privateState

local _interfacePrivateSelf = serviceSelf.privateState

local _interfacePrivateMethodSelf = serviceSelf:privateMethod()

-- Check: Interface Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _interfaceStaticObject = serviceObject.version

local _interfaceStaticMethodObject = serviceObject.formatVersion

-- Check: Interface Immutable Carry
-- Pass condition: this rejected access or assignment produces a type diagnostic.

serviceObject.settings.enabled = false

serviceObject.settings.nested.value = 123

-- Check: Trait Protected Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _traitProtectedObject = movableObject.protectedMultiplier

local _traitProtectedMethodObject = movableObject:protectedMove(1)

-- Check: Trait Private Not Inherited
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _traitPrivateObject = movableObject.privateCounter

local _traitPrivateSelf = movableSelf.privateCounter

local _traitPrivateMethodSelf = movableSelf:privateMove(1)

-- Check: Trait Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _traitStaticObject = movableObject.category

-- Check: Super Protected Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _superProtectedObject = playerObject.protectedValue

local _superProtectedMethodObject = playerObject:protectedMethod("hello")

-- Check: Super Private Not Inherited
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _superPrivateObject = playerObject.privateValue

local _superPrivateSelf = playerSelf.privateValue

local _superPrivateMethodSelf = playerSelf:privateMethod()

-- Check: Inherited Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _superStaticObject = playerObject.kind

local _superStaticCreateObject = playerObject.create

-- Check: Modifier Override
-- Pass condition: this rejected access or assignment produces a type diagnostic.

priorityObject.value = 123

local _priorityMethodColon = priorityObject:run("hello")

-- Check: Visibility Override
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _privateOverrideObject = visibilityObject.publicToPrivate

local _protectedOverrideObject = visibilityObject.publicToProtected

local _protectedPrivateObject = visibilityObject.protectedToPrivate

local _protectedMethodObject = visibilityObject:publicMethodToProtected("hello")

-- Check: Multi Level Visibility
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _grandchildFormerPrivateObject = grandchildObject.publicToPrivate

local _grandchildFormerPrivateSelf = grandchildSelf.publicToPrivate

local _grandchildPrivateProtectedObject = grandchildObject.protectedToPrivate

local _grandchildPrivateProtectedSelf = grandchildSelf.protectedToPrivate

local _grandchildProtectedObject = grandchildObject.publicToProtected

local _grandchildProtectedMethodObject = grandchildObject:publicMethodToProtected("hello")

-- Check: Mixed Protected
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _mixedProtectedObject = actorObject.protectedDebugId
