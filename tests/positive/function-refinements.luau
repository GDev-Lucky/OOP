--!strict

-- Test: Function refinements and immutable class-member indexers
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Base = oop.Class<{
	name: string,
	new: oop.Constructor<(string) -> oop.Object>,
	lookup: (string) -> string,
	variadic: (...string) -> string,
	pair: (string) -> (string, number),
}>

type Narrow = oop.Refine<Base, {
	name: "Red",
	new: ("Red") -> oop.Object,
	lookup: ("Red") -> "Red",
	variadic: (..."Red") -> "Red",
	pair: ("Red") -> ("Red", number),
}>

local refined: oop.ClassOf<Narrow> = nil :: any
local _name: "Red" = refined.new("Red").name
local object: oop.ObjectOf<Narrow> = nil :: any
local _lookup: "Red" = object:lookup("Red")
local _variadic: "Red" = object:variadic("Red", "Red")
local _pairName: "Red", _pairNumber: number = object:pair("Red")

type Nested = { score: number }

-- Check: Immut applies to a class member, not a standalone table alias.
-- Pass condition: the compiled object exposes the indexed nested score as a number.
type RecursiveClass = oop.Class<{ children: oop.Immut<{ [string]: Nested }> }>
local compiled: oop.ObjectOf<RecursiveClass> = nil :: any
local _nested: number = compiled.children.child.score
