--!strict

-- Test: Trait views and class composition
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Trait<T> = oop.Trait<T>
type Protected<T> = oop.Protected<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Field<T> = oop.Field<T>
type Var<T> = oop.Var<T>
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Traits
-- Pass condition: this section type-checks without diagnostics.
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

type MovementTraitSelf = SelfOf<MovementTrait>
type MovementTraitClass = ClassOf<MovementTrait>
type MovementTraitImpl = ImplOf<MovementTrait>

local movementTraitSelf: MovementTraitSelf = any()
local movementTraitClass: MovementTraitClass = any()
local movementTraitImpl: MovementTraitImpl = any()

local _traitSpeed: number = movementTraitSelf.speed

movementTraitSelf.speed = 10

local _traitProtectedMultiplier: number = movementTraitSelf.protectedMultiplier

movementTraitSelf.protectedMultiplier = 2

local _traitPrivateCounter: number = movementTraitSelf.privateCounter

movementTraitSelf.privateCounter = 10

local _traitCategory: string = movementTraitClass.category

function movementTraitImpl:move(value)
	local _self: MovementTraitSelf = self
	local _value: number = value

	return value
end

movementTraitImpl.transform = function(value)
	local _value: number = value

	return tostring(value)
end

function movementTraitImpl:protectedMove(value)
	local _self: MovementTraitSelf = self
	local _value: number = value
	local _multiplier: number = self.protectedMultiplier

	return value * _multiplier
end

function movementTraitImpl:privateMove(value)
	local _self: MovementTraitSelf = self
	local _value: number = value
	local _counter: number = self.privateCounter

	return value + _counter
end

movementTraitImpl.category = "movement"

-- Check: Trait Composition
-- Pass condition: this section type-checks without diagnostics.
type MovableSpec = {
	label: Var<string>,
}

type Movable = Class<MovableSpec, MovementTrait>

type MovableObject = ObjectOf<Movable>
type MovableSelf = SelfOf<Movable>
type MovableClass = ClassOf<Movable>
type MovableImpl = ImplOf<Movable>

local movableObject: MovableObject = any()
local movableSelf: MovableSelf = any()
local movableClass: MovableClass = any()
local movableImpl: MovableImpl = any()

local _movableLabel: string = movableObject.label

local _movableSpeed: number = movableObject.speed

movableObject.speed = 20

local _movableResult: number = movableObject:move(5)

local _movableTransform: string = movableObject.transform(100)

local _movableCategory: string = movableClass.category

local _movableProtectedMultiplier: number = movableSelf.protectedMultiplier

movableSelf.protectedMultiplier = 5

local _movableProtectedResult: number = movableSelf:protectedMove(10)

function movableImpl:move(value)
	local _self: MovableSelf = self
	local _label: string = self.label
	local _speed: number = self.speed
	local _value: number = value

	return value
end

function movableImpl:protectedMove(value)
	local _self: MovableSelf = self
	local _multiplier: number = self.protectedMultiplier

	return value * _multiplier
end
