--!strict

-- Test: Deep object and self reference rebinding
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Protected<T> = oop.Protected<T>
type Var<T> = oop.Var<T>
type Self = oop.Self
type Object = oop.Object
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>

local function any(): any
	return nil :: any
end

-- Check: Deep Reference Rebinding
-- Pass condition: this section type-checks without diagnostics.
type TreeBaseSpec = {
	parent: Var<Object?>,

	copy: () -> Object,

	protectedSelf: Protected<() -> Self>,

	metadata: {
		owner: Object,

		nested: {
			alternate: Object?,
		},
	},
}

type TreeBase = Class<TreeBaseSpec>

type TreeMiddleSpec = {
	middleValue: number,
}

type TreeMiddle = Class<TreeMiddleSpec, TreeBase>

type TreeLeafSpec = {
	leafValue: string,
}

type TreeLeaf = Class<TreeLeafSpec, TreeMiddle>

type TreeLeafObject = ObjectOf<TreeLeaf>
type TreeLeafSelf = SelfOf<TreeLeaf>

local treeLeaf: TreeLeafObject = any()
local treeLeafSelf: TreeLeafSelf = any()

local treeCopy: TreeLeafObject = treeLeaf:copy()

local _copyLeafValue: string = treeCopy.leafValue

local _copyMiddleValue: number = treeCopy.middleValue

local treeParent: TreeLeafObject? = treeLeaf.parent

if treeParent then
	local _parentLeafValue: string = treeParent.leafValue

	local _parentMiddleValue: number = treeParent.middleValue
end

local treeOwner: TreeLeafObject = treeLeaf.metadata.owner

local _ownerLeafValue: string = treeOwner.leafValue

local treeAlternate: TreeLeafObject? = treeLeaf.metadata.nested.alternate

if treeAlternate then
	local _alternateLeafValue: string = treeAlternate.leafValue
end

local protectedTreeSelf: TreeLeafSelf = treeLeafSelf:protectedSelf()

local _protectedLeafValue: string = protectedTreeSelf.leafValue

local _protectedMiddleValue: number = protectedTreeSelf.middleValue
