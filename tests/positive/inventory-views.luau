--!strict

-- Test: Inventory constructors, members, mutability, and view conversion
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.
-- Note: Indexer entry writes are supported; nested declared properties remain immutable.

local oop = require("../../src/types")

type Class<T> = oop.Class<T>
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
type ImplOf<T> = oop.ImplOf<T>
type SpecOf<T> = oop.SpecOf<T>
type ToClass<T> = oop.ToClass<T>
type ToObject<T> = oop.ToObject<T>
type ToSelf<T> = oop.ToSelf<T>
type ToImpl<T> = oop.ToImpl<T>
type View<T, K> = oop.View<T, K>
type ViewOf<T, K> = oop.ViewOf<T, K>

local function any(): any
	return nil :: any
end

type NumberFunction = (number) -> number

type GenericIdentity = <T>(T) -> T

-- Check: Complex Inventory
-- Pass condition: this section type-checks without diagnostics.
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

type InventoryObject = ObjectOf<Inventory>
type InventorySelf = SelfOf<Inventory>
type InventoryClass = ClassOf<Inventory>
type InventoryImpl = ImplOf<Inventory>

type InventoryRecoveredSpec = SpecOf<Inventory>

local inventoryClass: InventoryClass = any()
local inventoryImpl: InventoryImpl = any()

-- Check: Constructor Implementation
-- Pass condition: this section type-checks without diagnostics.
inventoryImpl.new = function(name, size)
	local _name: string = name
	local _size: number = size

	return any()
end

inventoryImpl.replaceableConstructor = function(name)
	local _name: string = name

	return any()
end

-- Check: Method Implementation
-- Pass condition: this section type-checks without diagnostics.
function inventoryImpl:description(prefix)
	local _self: InventorySelf = self
	local _prefix: string = prefix
	local _name: string = self.name

	return prefix .. self.name
end

function inventoryImpl:setSecret(value)
	local _self: InventorySelf = self
	local _value: string = value

	self.secret = value
end

function inventoryImpl:clone()
	local _self: InventorySelf = self

	return any()
end

function inventoryImpl:internalClone()
	local _self: InventorySelf = self
	local _secret: string = self.secret

	return self
end

function inventoryImpl:identity(value)
	return value
end

function inventoryImpl:pair()
	local _self: InventorySelf = self

	return 1, "hello"
end

function inventoryImpl:log(message, ...)
	local _self: InventorySelf = self
	local _message: string = message
	local _args = { ... }
end

-- Check: Field Function Implementation
-- Pass condition: this section type-checks without diagnostics.
inventoryImpl.callback = function(value, text)
	local _value: number = value
	local _text: string = text

	return value > 0 and text ~= ""
end

inventoryImpl.replaceableCallback = function(value)
	local _value: number = value

	return tostring(value)
end

-- Check: Static Implementation
-- Pass condition: this section type-checks without diagnostics.
inventoryImpl.version = "1.0.0"
inventoryImpl.globalCount = 0
inventoryImpl.internalCounter = 0

inventoryImpl.createEmpty = function()
	return any()
end

inventoryImpl.internalFactory = function(name)
	local _name: string = name

	return any()
end

-- Check: Constructor
-- Pass condition: this section type-checks without diagnostics.
local inventory: InventoryObject = inventoryClass.new("Backpack", 32)

local _replaceableInventory: InventoryObject = inventoryClass.replaceableConstructor("Temporary")

inventoryClass.replaceableConstructor = any()

-- Check: Public Fields
-- Pass condition: this section type-checks without diagnostics.
local _inventoryId: string = inventory.id
local _inventoryName: string = inventory.name
local _inventorySize: number = inventory.size

inventory.name = "New Name"

-- Check: Public Methods
-- Pass condition: this section type-checks without diagnostics.
local _description: string = inventory:description("prefix")

local _descriptionDot: string = inventory.description(inventory, "prefix")

-- Check: Self View
-- Pass condition: this section type-checks without diagnostics.
local inventorySelf: InventorySelf = any()

local _privateSecret: string = inventorySelf.secret

inventorySelf.secret = "secret"

-- Check: Field Functions
-- Pass condition: this section type-checks without diagnostics.
local _callbackResult: boolean = inventory.callback(123, "hello")

inventory.replaceableCallback = any()

-- Check: Object References
-- Pass condition: this section type-checks without diagnostics.
local clonedInventory: InventoryObject = inventory:clone()

local _clonedName: string = clonedInventory.name

local _maybeParent: InventoryObject? = inventory.parent

inventory.parent = clonedInventory
inventory.parent = nil

-- Check: Generic Method
-- Pass condition: this section type-checks without diagnostics.
local _identityNumber: number = inventory:identity(123)

local _identityString: string = inventory:identity("hello")

local _identityBoolean: boolean = inventory:identity(true)

local _identityTable: { value: number } = inventory:identity({
	value = 123,
})

-- Check: Multiple Returns
-- Pass condition: this section type-checks without diagnostics.
local _pairNumber: number, _pairString: string = inventory:pair()

-- Check: Variadic Method
-- Pass condition: this section type-checks without diagnostics.
inventory:log("message")

inventory:log("message", 1, true, "hello", {})

-- Check: Static Members
-- Pass condition: this section type-checks without diagnostics.
local _version: string = inventoryClass.version

local emptyInventory: InventoryObject = inventoryClass.createEmpty()

local _emptyInventoryName: string = emptyInventory.name

local _globalCount: number = inventoryClass.globalCount

inventoryClass.globalCount = 10

-- Check: Immutable Table
-- Pass condition: this section type-checks without diagnostics.
local _settingsLabel: string = inventory.settings.label

local _settingsActive: boolean = inventory.settings.flags.active

local _firstItemName: string = inventory.settings.items[1].name

local _indexEnabled: boolean = inventory.settings.index.foo.enabled

local _settingsOwner: InventoryObject = inventory.settings.owner

inventory.settings = any()

-- Check: Mutable Table With Const Property
-- Pass condition: this section type-checks without diagnostics.
inventory.state.count = 10
inventory.state.nested.value = "changed"

-- Check: Views
-- Pass condition: this section type-checks without diagnostics.
local directObjectView: ViewOf<Inventory, "object"> = any()
local directSelfView: ViewOf<Inventory, "self"> = any()
local directClassView: ViewOf<Inventory, "class"> = any()
local directImplView: ViewOf<Inventory, "impl"> = any()

local _viewObjectName: string = directObjectView.name

local _viewSelfSecret: string = directSelfView.secret

local _viewClassVersion: string = directClassView.version

directImplView.version = "2.0.0"
directImplView.globalCount = 100
directImplView.internalCounter = 100

-- Check: Conversion
-- Pass condition: this section type-checks without diagnostics.
type InventoryToObject = ToObject<Inventory>
type InventoryToSelf = ToSelf<Inventory>
type InventoryToClass = ToClass<Inventory>
type InventoryToImpl = ToImpl<Inventory>

local convertedObject: InventoryToObject = any()
local convertedSelf: InventoryToSelf = any()
local convertedClass: InventoryToClass = any()
local convertedImpl: InventoryToImpl = any()

local _convertedName: string = convertedObject.name

local _convertedSecret: string = convertedSelf.secret

local _convertedVersion: string = convertedClass.version

convertedImpl.version = "3.0.0"
convertedImpl.internalCounter = 100

-- Check: Repeated Conversion
-- Pass condition: this section type-checks without diagnostics.
type InventoryClassAgain = ToClass<InventoryToObject>
type InventoryObjectAgain = ToObject<InventoryToClass>
type InventoryImplAgain = ToImpl<InventoryToSelf>

local classAgain: InventoryClassAgain = any()
local objectAgain: InventoryObjectAgain = any()
local implAgain: InventoryImplAgain = any()

local _classAgainVersion: string = classAgain.version

local _objectAgainName: string = objectAgain.name

implAgain.version = "4.0.0"
implAgain.internalCounter = 100

-- Check: Spec Extraction
-- Pass condition: this section type-checks without diagnostics.
local originalInventorySpec: InventorySpec = any()

local recoveredInventorySpec: InventoryRecoveredSpec = originalInventorySpec

local _restoredInventorySpec: InventorySpec = recoveredInventorySpec

-- Check: Immutable indexed entries can be replaced.
-- Pass condition: indexed-entry writes type-check without diagnostics.
inventory.settings.items[1] = any()
inventory.settings.index.foo = {
	enabled = false,
}

-- Check: Implementation members can be read and called with an explicit self.
-- Pass condition: functions and static fields are readable on the implementation view.
local _implSetSecret = inventoryImpl.setSecret
local _implDescription = inventoryImpl.description
local _implCallback = inventoryImpl.callback
local _implVersion: string = inventoryImpl.version
local _implCounter: number = inventoryImpl.internalCounter
inventoryImpl.callback(1, "hello")
inventoryImpl.description(inventorySelf, "hello")
