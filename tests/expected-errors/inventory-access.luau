--!strict

-- Test: Inventory constructor, visibility, and immutable member rejection
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Public<T> = oop.Public<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Method<T> = oop.Method<T>
type Field<T> = oop.Field<T>
type Const<T> = oop.Const<T>
type Var<T> = oop.Var<T>
type Mut<T> = oop.Mut<T>
type Immut<T> = oop.Immut<T>
type Constructor<T> = oop.Constructor<T>
type Self = oop.Self
type Object = oop.Object
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>

local function any(): any
	return nil :: any
end

type NumberFunction = (number) -> number

type GenericIdentity = <T>(T) -> T
type InventorySpec = {
	new: Constructor<(string, number) -> boolean>,

	replaceableConstructor: Var<Constructor<(string) -> number>>,

	id: Const<string>,
	name: Var<string>,

	size: number,

	secret: Private<Var<string>>,

	description: (string) -> string,

	setSecret: Private<(string) -> ()>,

	callback: Field<(number, string) -> boolean>,

	replaceableCallback: Var<Field<(number) -> string>>,

	clone: () -> Object,

	internalClone: Private<() -> Self>,

	identity: GenericIdentity,

	pair: () -> (number, string),

	log: (string, ...any) -> (),

	version: Static<string>,

	createEmpty: Static<() -> Object>,

	globalCount: Var<Static<number>>,

	internalCounter: Private<Static<Var<number>>>,

	internalFactory: Private<Static<(string) -> Object>>,

	settings: Immut<Var<{
		label: string,

		flags: {
			active: boolean,
			visible: boolean,
		},

		items: {
			{
				id: number,
				name: string,
			}
		},

		index: {
			[string]: {
				enabled: boolean,
			},
		},

		owner: Object,
	}>>,

	state: Mut<Const<{
		count: number,

		nested: {
			value: string,
		},
	}>>,

	parent: Var<Object?>,
}

type Inventory = Class<InventorySpec>
local inventory: ObjectOf<Inventory> = nil :: any
local inventorySelf: SelfOf<Inventory> = nil :: any
local inventoryClass: ClassOf<Inventory> = nil :: any

-- Check: Constructor Visibility
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _constructorOnObject = inventory.new

local _constructorOnSelf = inventorySelf.new

-- Check: Constructor Const On Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

inventoryClass.new = any()

-- Check: Public Const
-- Pass condition: this rejected access or assignment produces a type diagnostic.

inventory.id = "changed"
inventory.size = 123

-- Check: Private
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _secretFromObject = inventory.secret

inventory:setSecret("no")

local _internalCloneFromObject = inventory:internalClone()

-- Check: Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _versionFromObject = inventory.version

local _createFromObject = inventory.createEmpty

local _globalCountFromObject = inventory.globalCount

-- Check: Static Not On Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _versionFromSelf = inventorySelf.version

local _globalCountFromSelf = inventorySelf.globalCount

-- Check: Private Static Not On Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _internalCounterFromClass = inventoryClass.internalCounter

local _internalFactoryFromClass = inventoryClass.internalFactory

-- Check: Field Function Does Not Inject Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _callbackColon = inventory:callback(123, "hello")

-- Check: Method Requires Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _descriptionMissingSelf = inventory.description("hello")

local _identityMissingSelf = inventory.identity(123)

-- Check: Immutable Settings
-- Pass condition: this rejected access or assignment produces a type diagnostic.

inventory.settings.label = "no"

inventory.settings.flags.active = false

inventory.settings.items[1].name = "no"

inventory.settings.index.foo.enabled = false

inventory.settings.owner = any()

-- Check: Mutable Contents Do Not Affect Const Property
-- Pass condition: this rejected access or assignment produces a type diagnostic.

inventory.state = any()
