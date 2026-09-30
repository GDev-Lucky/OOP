--!strict

-- Test: Explicit parent collision resolution and parent order
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Interface<T> = oop.Interface<T>
type Trait<T> = oop.Trait<T>
type Override<T> = oop.Override<T>
type Field<T> = oop.Field<T>
type ObjectOf<T> = oop.ObjectOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Local Spec Beats Composed Parent
-- Pass condition: this section type-checks without diagnostics.
type PriorityInterface = Interface<{
	shared: number,
	method: (number) -> number,
}>

type LocalPrioritySpec = {
	shared: string,
	method: Field<(string) -> boolean>,
}

type LocalPriority = Class<LocalPrioritySpec, PriorityInterface>

type LocalPriorityObject = ObjectOf<LocalPriority>
type LocalPriorityImpl = ImplOf<LocalPriority>

local localPriorityObject: LocalPriorityObject = any()
local localPriorityImpl: LocalPriorityImpl = any()

local _localPriorityShared: string = localPriorityObject.shared

local _localPriorityMethod: boolean = localPriorityObject.method("hello")

localPriorityImpl.method = function(value)
	local _value: string = value

	return value ~= ""
end

-- Check: Collision Sources
-- Pass condition: this section type-checks without diagnostics.
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

-- Check: Override Interface Order
-- Pass condition: this section type-checks without diagnostics.
type NumberFirst = Override<Class<{}, NumberInterface, StringInterface>>

type NumberFirstObject = ObjectOf<NumberFirst>

local numberFirst: NumberFirstObject = any()

local _numberFirstCollision: number = numberFirst.collision

local _numberFirstNumberOnly: number = numberFirst.numberOnly

local _numberFirstStringOnly: string = numberFirst.stringOnly

type StringFirst = Override<Class<{}, StringInterface, NumberInterface>>

type StringFirstObject = ObjectOf<StringFirst>

local stringFirst: StringFirstObject = any()

local _stringFirstCollision: string = stringFirst.collision

local _stringFirstNumberOnly: number = stringFirst.numberOnly

local _stringFirstStringOnly: string = stringFirst.stringOnly

-- Check: Override Trait Interface Order
-- Pass condition: this section type-checks without diagnostics.
type TraitFirst = Override<Class<{}, BooleanTrait, NumberInterface, StringInterface>>

type TraitFirstObject = ObjectOf<TraitFirst>

local traitFirst: TraitFirstObject = any()

local _traitFirstCollision: boolean = traitFirst.collision

local _traitFirstBooleanOnly: boolean = traitFirst.booleanOnly

local _traitFirstNumberOnly: number = traitFirst.numberOnly

local _traitFirstStringOnly: string = traitFirst.stringOnly

type InterfaceFirst = Override<Class<{}, StringInterface, BooleanTrait, NumberInterface>>

type InterfaceFirstObject = ObjectOf<InterfaceFirst>

local interfaceFirst: InterfaceFirstObject = any()

local _interfaceFirstCollision: string = interfaceFirst.collision

-- Check: Override Super Order
-- Pass condition: this section type-checks without diagnostics.
type SuperFirst = Override<Class<{}, SuperCollision, NumberInterface, BooleanTrait>>

type SuperFirstObject = ObjectOf<SuperFirst>

local superFirst: SuperFirstObject = any()

local _superFirstCollision: {
	source: "super",
} = superFirst.collision

local _superFirstOnly: number = superFirst.superOnly

local _superFirstNumberOnly: number = superFirst.numberOnly

local _superFirstBooleanOnly: boolean = superFirst.booleanOnly

type SuperLast = Override<Class<{}, BooleanTrait, NumberInterface, SuperCollision>>

type SuperLastObject = ObjectOf<SuperLast>

local superLast: SuperLastObject = any()

local _superLastCollision: boolean = superLast.collision

local _superLastOnly: number = superLast.superOnly

-- Check: Local Spec With Override
-- Pass condition: this section type-checks without diagnostics.
type LocalOverrideSpec = {
	collision: "local",
}

type LocalOverride = Override<Class<LocalOverrideSpec, NumberInterface, StringInterface, BooleanTrait, SuperCollision>>

type LocalOverrideObject = ObjectOf<LocalOverride>

local localOverride: LocalOverrideObject = any()

local _localOverrideCollision: "local" = localOverride.collision

local _localOverrideNumberOnly: number = localOverride.numberOnly

local _localOverrideStringOnly: string = localOverride.stringOnly

local _localOverrideBooleanOnly: boolean = localOverride.booleanOnly

local _localOverrideSuperOnly: number = localOverride.superOnly
