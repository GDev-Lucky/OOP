--!strict

-- Test: Mixed interface, trait, and superclass composition
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Interface<T> = oop.Interface<T>
type Trait<T> = oop.Trait<T>
type Protected<T> = oop.Protected<T>
type Var<T> = oop.Var<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Mixed Composition
-- Pass condition: this section type-checks without diagnostics.
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

type ComplexActorObject = ObjectOf<ComplexActor>
type ComplexActorSelf = SelfOf<ComplexActor>
type ComplexActorImpl = ImplOf<ComplexActor>

local actorObject: ComplexActorObject = any()
local actorSelf: ComplexActorSelf = any()
local actorImpl: ComplexActorImpl = any()

local _actorActive: boolean = actorObject.active

local _actorX: number = actorObject.x

local _actorY: number = actorObject.y

local _actorHealth: number = actorObject.health

local _actorDisplayName: string = actorObject.displayName

local _actorId: number = actorObject.actorId

local _actorDebugName: string = actorObject.debugName

local _actorHeal: number = actorObject:heal(10)

local _actorDisplay: string = actorObject:getDisplayName()

local _actorSerialize: string = actorObject:serialize()

local _actorDebug: string = actorObject:debug()

local _actorProtectedDebugId: number = actorSelf.protectedDebugId

actorSelf.protectedDebugId = 123

function actorImpl:heal(value)
	local _self: ComplexActorSelf = self
	local _value: number = value
	local _health: number = self.health

	return _health + value
end

function actorImpl:moveTo(x, y)
	local _self: ComplexActorSelf = self
	local _x: number = x
	local _y: number = y
end

function actorImpl:debug()
	local _self: ComplexActorSelf = self
	local _id: number = self.protectedDebugId

	return tostring(_id)
end

function actorImpl:getDisplayName()
	local _self: ComplexActorSelf = self

	return self.displayName
end

function actorImpl:getActorId()
	local _self: ComplexActorSelf = self

	return self.actorId
end

function actorImpl:serialize()
	local _self: ComplexActorSelf = self

	return self.displayName
end
