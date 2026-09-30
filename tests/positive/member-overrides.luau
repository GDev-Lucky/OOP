--!strict

-- Test: Local member priority and visibility overrides
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Override<T> = oop.Override<T>
type Public<T> = oop.Public<T>
type Protected<T> = oop.Protected<T>
type Private<T> = oop.Private<T>
type Method<T> = oop.Method<T>
type Field<T> = oop.Field<T>
type Var<T> = oop.Var<T>
type Mut<T> = oop.Mut<T>
type Immut<T> = oop.Immut<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Local Spec Priority
-- Pass condition: this section type-checks without diagnostics.
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

type ChildPriorityObject = ObjectOf<ChildPriority>
type ChildPrioritySelf = SelfOf<ChildPriority>
type ChildPriorityImpl = ImplOf<ChildPriority>

local priorityObject: ChildPriorityObject = any()
local priorityImpl: ChildPriorityImpl = any()

local _priorityValue: string = priorityObject.value

priorityObject.value = "changed"

local _priorityRun: boolean = priorityObject.run("hello")

local _priorityCallback: number = priorityObject:callback("hello")

priorityObject.state.value = 123

priorityImpl.run = function(value)
	local _value: string = value

	return value ~= ""
end

function priorityImpl:callback(value)
	local _self: ChildPrioritySelf = self
	local _value: string = value

	return #value
end

-- Check: Visibility Override
-- Pass condition: this section type-checks without diagnostics.
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

type VisibilityChildObject = ObjectOf<VisibilityChild>
type VisibilityChildSelf = SelfOf<VisibilityChild>
type VisibilityChildImpl = ImplOf<VisibilityChild>

local visibilityObject: VisibilityChildObject = any()
local visibilitySelf: VisibilityChildSelf = any()
local visibilityImpl: VisibilityChildImpl = any()

local _promotedProtected: string = visibilityObject.protectedToPublic

visibilityObject.protectedToPublic = "public"

local _privateOverride: string = visibilitySelf.publicToPrivate

visibilitySelf.publicToPrivate = "private"

local _protectedOverride: string = visibilitySelf.publicToProtected

visibilitySelf.publicToProtected = "protected"

local _protectedPrivateOverride: string = visibilitySelf.protectedToPrivate

visibilitySelf.protectedToPrivate = "private"

local _promotedMethod: string = visibilityObject:protectedMethodToPublic("hello")

local _protectedMethod: string = visibilitySelf:publicMethodToProtected("hello")

function visibilityImpl:publicMethodToProtected(value)
	local _self: VisibilityChildSelf = self
	local _value: string = value

	return value
end

function visibilityImpl:protectedMethodToPublic(value)
	local _self: VisibilityChildSelf = self
	local _value: string = value

	return value
end

-- Check: Multi Level Inheritance
-- Pass condition: this section type-checks without diagnostics.
type VisibilityGrandchildSpec = {
	grandchildOnly: boolean,
}

type VisibilityGrandchild = Class<VisibilityGrandchildSpec, VisibilityChild>

type VisibilityGrandchildObject = ObjectOf<VisibilityGrandchild>
type VisibilityGrandchildSelf = SelfOf<VisibilityGrandchild>
type VisibilityGrandchildImpl = ImplOf<VisibilityGrandchild>

local grandchildObject: VisibilityGrandchildObject = any()
local grandchildSelf: VisibilityGrandchildSelf = any()
local grandchildImpl: VisibilityGrandchildImpl = any()

local _grandchildOnly: boolean = grandchildObject.grandchildOnly

local _grandchildPublicPromoted: string = grandchildObject.protectedToPublic

local _grandchildProtectedInherited: string = grandchildSelf.publicToProtected

local _grandchildPublicMethod: string = grandchildObject:protectedMethodToPublic("hello")

local _grandchildProtectedMethod: string = grandchildSelf:publicMethodToProtected("hello")

function grandchildImpl:publicMethodToProtected(value)
	local _self: VisibilityGrandchildSelf = self
	local _grandchild: boolean = self.grandchildOnly
	local _value: string = value

	return value
end

-- Check: Field functions do not inject self through dot calls.
-- Pass condition: the callback accepts the explicit object argument.
local _priorityFieldDot = priorityObject.callback(priorityObject, "hello")
