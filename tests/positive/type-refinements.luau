--!strict

-- Test: Type-only specialization, parent replacement, and trait refinement
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Base = oop.Class<{
	color: string,
	bounce: () -> (),
	baseOnly: number,
	new: oop.Constructor<(string) -> oop.Object>,
	getBalls: oop.Static<() -> { oop.Object }>,
}>

type Ball<T> = oop.Refine<Base, {
	color: T,
	new: (T) -> oop.Object,
}>

type WithBaseReturn<T> = oop.Refine<Base, {
	color: T,
	new: (T) -> oop.ObjectOf<Base>,
}>

local red: oop.ObjectOf<Ball<"Red">> = nil :: any
local _redColor: "Red" = red.color
red:bounce()
local _baseOnly: number = red.baseOnly
local redClass: oop.ClassOf<Ball<"Red">> = nil :: any
local _newRed: "Red" = redClass.new("Red").color
local _baseBalls: string = redClass.getBalls()[1].color
local baseClass: oop.ClassOf<Base> = nil :: any
local _baseConstructor: string = baseClass.new("Blue").color
local _baseFromRefinement: oop.BaseOf<Ball<"Red">> = baseClass
local _baseFromView: oop.ToBase<oop.ToObject<Ball<"Red">>> = baseClass
local baseReturn: oop.ClassOf<WithBaseReturn<"Red">> = nil :: any
local _baseReturnColor: string = baseReturn.new("Red").color

type Blue = oop.ObjectOf<Ball<"Blue">>
local blue: Blue = nil :: any
local _blueColor: "Blue" = blue.color

type DoubleRefined = oop.Refine<Ball<string>, { color: "Red" }>
local twice: oop.ObjectOf<DoubleRefined> = nil :: any
local _twiceColor: "Red" = twice.color
local twiceClass: oop.ClassOf<DoubleRefined> = nil :: any
local _twiceNew: "Red" = twiceClass.new("Red").color
local _twiceBaseBalls: string = twiceClass.getBalls()[1].color

-- Check: A refined parent replaces the earlier specialization of the same family.
-- Pass condition: this section type-checks without diagnostics.
type ParentBase = oop.Class<{
	shade: string,
	bounceParent: () -> (),
}>
type Parent<T> = oop.Refine<ParentBase, { shade: T }>
type ChildBase = oop.Class<{ child: boolean }, Parent<"Blue">>
type Child<T> = oop.Refine<ChildBase, {}, Parent<T>>
type DirectChild = oop.Class<{ own: boolean }, Parent<"Red">>
type RedChild = oop.Class<{ extra: number }, Child<"Red">>
local _baseParentArguments: oop.ParentsOf<DirectChild, oop.ClassType, true> = nil :: any
local _refinedParentArguments: oop.ParentsOf<DirectChild, oop.ClassType> = nil :: any

local child: oop.ObjectOf<RedChild> = nil :: any
local _childShade: "Red" = child.shade
child:bounceParent()
local _childOwn: boolean = child.child
local _childExtra: number = child.extra
local direct: oop.ObjectOf<DirectChild> = nil :: any
local _directShade: "Red" = direct.shade
local _baseParentClass: oop.BaseOf<Parent<"Red">> = nil :: any

-- Check: Composition can also add an unrelated trait through refinement.
-- Pass condition: this section type-checks without diagnostics.
type Named = oop.Trait<{ name: string }>
type NamedBall<T> = oop.Refine<Base, { color: T }, Named>
local named: oop.ObjectOf<NamedBall<"Red">> = nil :: any
local _name: string = named.name

-- Check: Replacing a trait removes the old specialization; unrelated parents survive.
-- Pass condition: this section type-checks without diagnostics.
type TraitBase = oop.Class<{ marker: string, shared: boolean }>
type SpecialTrait<T> = oop.Refine<TraitBase, { marker: T }>
type HasTraits = oop.Class<{ own: number }, SpecialTrait<"Old">, Named>
type NewTraits = oop.Refine<HasTraits, {}, SpecialTrait<"New">>
local traits: oop.ObjectOf<NewTraits> = nil :: any
local _newMarker: "New" = traits.marker
local _unrelated: string = traits.name
local _traitsOwn: number = traits.own

local _checkedFields: oop.AssertObjectValuesOf<DirectChild, { own: boolean, shade: "Red" }> =
	{ own = true, shade = "Red" }

-- Note: unrelated parents with structurally identical bases cannot be distinguished by family identity.
