--!strict

-- Test: Single-class modifier precedence and views
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.
-- Note: Indexed-entry writes are checked in positive/inventory-views.luau.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
type Public<T> = oop.Public<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Method<T> = oop.Method<T>
type Field<T> = oop.Field<T>
type Const<T> = oop.Const<T>
type Var<T> = oop.Var<T>
type Mut<T> = oop.Mut<T>
type Immut<T> = oop.Immut<T>
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

type NumberFunction = (number) -> number

type NestedMutable = {
	value: number,

	nested: {
		text: string,

		deeper: {
			flag: boolean,
		},
	},

	array: {
		{
			score: number,
		}
	},

	dictionary: {
		[string]: {
			count: number,
		},
	},
}

-- Check: Modifier Matrix
-- Pass condition: this section type-checks without diagnostics.
type ModifierMatrixSpec = {
	defaultValue: number,
	defaultMethod: (number) -> number,

	explicitPublic: Public<number>,
	explicitPrivate: Private<number>,

	publicMethod: Public<(number) -> number>,
	privateMethod: Private<(number) -> number>,

	publicWins: Public<Private<number>>,
	privateWins: Private<Public<number>>,

	defaultStatic: Static<number>,

	publicStaticA: Public<Static<number>>,
	publicStaticB: Static<Public<number>>,

	privateStaticA: Private<Static<number>>,
	privateStaticB: Static<Private<number>>,

	publicStaticFunction: Public<Static<NumberFunction>>,
	privateStaticFunction: Private<Static<NumberFunction>>,

	explicitMethod: Method<NumberFunction>,
	explicitField: Field<NumberFunction>,

	fieldWins: Field<Method<NumberFunction>>,
	methodWins: Method<Field<NumberFunction>>,

	staticForcesField: Static<Method<NumberFunction>>,
	methodOverridesStatic: Method<Static<NumberFunction>>,

	defaultConst: number,

	explicitConst: Const<number>,
	explicitVar: Var<number>,

	varWins: Var<Const<number>>,
	constWins: Const<Var<number>>,

	varMethod: Var<Method<NumberFunction>>,
	varField: Var<Field<NumberFunction>>,

	varStatic: Var<Static<number>>,
	constStatic: Const<Static<number>>,

	defaultMutable: NestedMutable,

	explicitMut: Mut<NestedMutable>,
	explicitImmut: Immut<NestedMutable>,

	mutWins: Mut<Immut<NestedMutable>>,
	immutWins: Immut<Mut<NestedMutable>>,

	constMutable: Const<Mut<NestedMutable>>,
	varImmutable: Var<Immut<NestedMutable>>,
}

type ModifierMatrix = Class<ModifierMatrixSpec>

type ModifierMatrixObject = ObjectOf<ModifierMatrix>
type ModifierMatrixSelf = SelfOf<ModifierMatrix>
type ModifierMatrixClass = ClassOf<ModifierMatrix>
type ModifierMatrixImpl = ImplOf<ModifierMatrix>

local matrixObject: ModifierMatrixObject = any()
local matrixSelf: ModifierMatrixSelf = any()
local matrixClass: ModifierMatrixClass = any()
local matrixImpl: ModifierMatrixImpl = any()

-- Check: Method Implementation
-- Pass condition: this section type-checks without diagnostics.
function matrixImpl:defaultMethod(value)
	local _self: ModifierMatrixSelf = self
	local _value: number = value

	return value
end

function matrixImpl:publicMethod(value)
	local _self: ModifierMatrixSelf = self
	local _value: number = value

	return value
end

function matrixImpl:privateMethod(value)
	local _self: ModifierMatrixSelf = self
	local _privateValue: number = self.explicitPrivate

	return value
end

function matrixImpl:explicitMethod(value)
	local _self: ModifierMatrixSelf = self

	return value
end

function matrixImpl:methodWins(value)
	local _self: ModifierMatrixSelf = self

	return value
end

function matrixImpl:methodOverridesStatic(value)
	local _self: ModifierMatrixSelf = self

	return value
end

function matrixImpl:varMethod(value)
	local _self: ModifierMatrixSelf = self

	return value
end

-- Check: Field Function Implementation
-- Pass condition: this section type-checks without diagnostics.
matrixImpl.explicitField = function(value)
	local _value: number = value

	return value
end

matrixImpl.fieldWins = function(value)
	return value
end

matrixImpl.staticForcesField = function(value)
	return value
end

matrixImpl.publicStaticFunction = function(value)
	return value
end

matrixImpl.privateStaticFunction = function(value)
	return value
end

matrixImpl.varField = function(value)
	return value
end

-- Check: Static Field Implementation
-- Pass condition: this section type-checks without diagnostics.
matrixImpl.defaultStatic = 1

matrixImpl.publicStaticA = 2
matrixImpl.publicStaticB = 3

matrixImpl.privateStaticA = 4
matrixImpl.privateStaticB = 5

matrixImpl.varStatic = 6
matrixImpl.constStatic = 7

-- Check: Defaults
-- Pass condition: this section type-checks without diagnostics.
local _defaultValue: number = matrixObject.defaultValue

local _defaultMethodA: number = matrixObject:defaultMethod(10)
local _defaultMethodB: number = matrixObject.defaultMethod(matrixObject, 10)

-- Check: Visibility
-- Pass condition: this section type-checks without diagnostics.
local _explicitPublic: number = matrixObject.explicitPublic

local _publicWins: number = matrixObject.publicWins

local _privateFromSelf: number = matrixSelf.explicitPrivate
local _privateWinsFromSelf: number = matrixSelf.privateWins

local _privateMethodResult: number = matrixSelf:privateMethod(1)
local _publicMethodResult: number = matrixObject:publicMethod(1)

-- Check: Static
-- Pass condition: this section type-checks without diagnostics.
local _defaultStatic: number = matrixClass.defaultStatic

local _publicStaticA: number = matrixClass.publicStaticA
local _publicStaticB: number = matrixClass.publicStaticB

local _staticFunctionA: number = matrixClass.publicStaticFunction(1)

-- Check: Injectability
-- Pass condition: this section type-checks without diagnostics.
local _methodA: number = matrixObject:explicitMethod(1)
local _methodB: number = matrixObject.explicitMethod(matrixObject, 1)

local _fieldA: number = matrixObject.explicitField(1)

local _fieldWins: number = matrixObject.fieldWins(1)

local _methodWinsA: number = matrixObject:methodWins(1)
local _methodWinsB: number = matrixObject.methodWins(matrixObject, 1)

local _staticForcedField: number = matrixClass.staticForcesField(1)

local _staticMethodOverrideA: number = matrixClass:methodOverridesStatic(1)
local _staticMethodOverrideB: number = matrixClass.methodOverridesStatic(matrixClass, 1)

-- Check: Assignability
-- Pass condition: this section type-checks without diagnostics.
matrixObject.explicitVar = 100
matrixObject.varWins = 100

matrixObject.varMethod = any()
matrixObject.varField = any()

matrixClass.varStatic = 100

-- Check: Mutability
-- Pass condition: this section type-checks without diagnostics.
matrixObject.defaultMutable.value = 1
matrixObject.defaultMutable.nested.text = "changed"
matrixObject.defaultMutable.nested.deeper.flag = true

matrixObject.defaultMutable.array[1].score = 50
matrixObject.defaultMutable.dictionary.foo.count = 10

matrixObject.explicitMut.value = 1
matrixObject.explicitMut.nested.text = "changed"

matrixObject.mutWins.value = 1
matrixObject.mutWins.nested.deeper.flag = true

matrixObject.mutWins.array[1].score = 100
matrixObject.mutWins.dictionary.foo.count = 20

matrixObject.constMutable.value = 1
matrixObject.constMutable.nested.text = "changed"

matrixObject.varImmutable = any()
