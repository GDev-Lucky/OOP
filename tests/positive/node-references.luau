--!strict

-- Test: Node object and self reference rebinding
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Method<T> = oop.Method<T>
type Var<T> = oop.Var<T>
type Immut<T> = oop.Immut<T>
type Constructor<T> = oop.Constructor<T>
type Self = oop.Self
type Object = oop.Object
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Reference Heavy Class
-- Pass condition: this section type-checks without diagnostics.
type NodeSpec = {
	new: Constructor<(string) -> ()>,

	name: Var<string>,

	parent: Var<Object?>,

	getParent: () -> Object?,

	setParent: (Object?) -> (),

	copy: () -> Object,

	privateSelf: Private<() -> Self>,

	metadata: Immut<{
		owner: Object,

		links: {
			primary: Object?,
			secondary: Object?,
		},

		data: {
			[string]: {
				value: number,
			},
		},
	}>,

	create: Static<(string) -> Object>,
}

type Node = Class<NodeSpec>

type NodeObject = ObjectOf<Node>
type NodeSelf = SelfOf<Node>
type NodeClass = ClassOf<Node>
type NodeImpl = ImplOf<Node>

local nodeClass: NodeClass = any()
local nodeImpl: NodeImpl = any()

-- Check: Implementation methods and static members can be read.
-- Pass condition: their types are available through the implementation view.
local _nodeImplSetParent = nodeImpl.setParent
local _nodeImplCopy = nodeImpl.copy
local _nodeImplCreate = nodeImpl.create

-- Check: Indexed metadata entries may be replaced.
-- Pass condition: replacing an indexed entry type-checks even when its fields are immutable.
local indexedNode: NodeObject = any()
indexedNode.metadata.data.foo = any()

-- Check: Node Constructor Implementation
-- Pass condition: this section type-checks without diagnostics.
nodeImpl.new = function(name)
	local _name: string = name

	return any()
end

-- Check: Node Method Implementation
-- Pass condition: this section type-checks without diagnostics.
function nodeImpl:getParent()
	local _self: NodeSelf = self

	return self.parent
end

function nodeImpl:setParent(parent)
	local _self: NodeSelf = self
	local _parent: NodeObject? = parent

	self.parent = parent
end

function nodeImpl:copy()
	local _self: NodeSelf = self

	return any()
end

function nodeImpl:privateSelf()
	local _self: NodeSelf = self

	return self
end

-- Check: Node Static Implementation
-- Pass condition: this section type-checks without diagnostics.
nodeImpl.create = function(name)
	local _name: string = name

	return any()
end

-- Check: Node Usage
-- Pass condition: this section type-checks without diagnostics.
local node: NodeObject = nodeClass.new("root")

node.name = "renamed"
node.parent = nil

local nodeCopy: NodeObject = node:copy()

local _nodeParent: NodeObject? = node:getParent()

node:setParent(nodeCopy)
node:setParent(nil)

local nodeSelf: NodeSelf = any()

local _nodeSelfName: string = nodeSelf.name

local _metadataOwner: NodeObject = node.metadata.owner

local _primaryLink: NodeObject? = node.metadata.links.primary

local _metadataValue: number = node.metadata.data.foo.value

local _createdNode: NodeObject = nodeClass.create("child")
