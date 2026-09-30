--!strict

-- Test: Constructors return the compiled object view
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
type Constructor<T> = oop.Constructor<T>
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Forced Constructor Return
-- Pass condition: this section type-checks without diagnostics.
type ForcedConstructorSpec = {
	new: Constructor<(number) -> string>,
	value: number,
}

type ForcedConstructor = Class<ForcedConstructorSpec>

type ForcedConstructorClass = ClassOf<ForcedConstructor>

type ForcedConstructorObject = ObjectOf<ForcedConstructor>

type ForcedConstructorImpl = ImplOf<ForcedConstructor>

local forcedConstructorClass: ForcedConstructorClass = any()

local forcedConstructorImpl: ForcedConstructorImpl = any()

forcedConstructorImpl.new = function(value)
	local _value: number = value

	return any()
end

local forcedObject: ForcedConstructorObject = forcedConstructorClass.new(123)

local _forcedValue: number = forcedObject.value
