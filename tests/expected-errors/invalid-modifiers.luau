--!strict

-- Test: Invalid constructor and immutable modifier types
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
type Immut<T> = oop.Immut<T>
type Constructor<T> = oop.Constructor<T>
type ObjectOf<T> = oop.ObjectOf<T>

-- Check: Invalid constructor declaration
-- Pass condition: expanding the class reports that constructors must be functions.

type BadConstructor = Class<{
	new: Constructor<number>,
}>
type RejectedConstructor = ObjectOf<BadConstructor>

-- Check: Immutable scalar
-- Pass condition: expanding the class rejects Immut on a number.
type BadImmutNumber = Class<{
	value: Immut<number>,
}>
type RejectedImmutNumber = ObjectOf<BadImmutNumber>

-- Check: Immutable function
-- Pass condition: expanding the class rejects Immut on a function.
type BadImmutFunction = Class<{
	callback: Immut<() -> ()>,
}>
type RejectedImmutFunction = ObjectOf<BadImmutFunction>
