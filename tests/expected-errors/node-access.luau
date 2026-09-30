--!strict

-- Test: Node immutable metadata and private or static access rejection
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Var<T> = oop.Var<T>
type Immut<T> = oop.Immut<T>
type Constructor<T> = oop.Constructor<T>
type Self = oop.Self
type Object = oop.Object
type ObjectOf<T> = oop.ObjectOf<T>

local function any(): any
	return nil :: any
end

-- Check: Reference Heavy Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

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
local node: NodeObject = any()

-- Check: Immutable Node Metadata
-- Pass condition: this rejected access or assignment produces a type diagnostic.

node.metadata.owner = any()

node.metadata.links.primary = nil

node.metadata.data.foo.value = 123

node.metadata = any()

-- Check: Private Method
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _privateSelfFromNode = node:privateSelf()

-- Check: Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _createFromNode = node.create
