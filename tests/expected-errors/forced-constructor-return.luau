--!strict

-- Test: Constructor return cannot be treated as original return type
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Constructor<T> = oop.Constructor<T>
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

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

-- Expected error:
-- Constructor discarded the original string return.

local _forcedString: string = forcedConstructorClass.new(123)
