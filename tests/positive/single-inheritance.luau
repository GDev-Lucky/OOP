--!strict

-- Test: Inherited members, constructors, and self rebinding
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Protected<T> = oop.Protected<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Var<T> = oop.Var<T>
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

-- Check: Single Inheritance
-- Pass condition: this section type-checks without diagnostics.
type EntitySpec = {
	new: Constructor<(string) -> ()>,

	id: Var<string>,

	enabled: Var<boolean>,

	clone: () -> Object,

	parent: Var<Object?>,

	getSelf: Protected<() -> Self>,

	protectedValue: Protected<Var<number>>,

	protectedMethod: Protected<(string) -> string>,

	privateValue: Private<Var<string>>,

	privateMethod: Private<() -> string>,

	kind: Static<string>,

	create: Static<(string) -> Object>,
}

type Entity = Class<EntitySpec>

type EntityObject = ObjectOf<Entity>
type EntitySelf = SelfOf<Entity>
type EntityClass = ClassOf<Entity>
type EntityImpl = ImplOf<Entity>

local entityObject: EntityObject = any()
local entitySelf: EntitySelf = any()
local entityClass: EntityClass = any()
local entityImpl: EntityImpl = any()

local _entityId: string = entityObject.id

local _entityEnabled: boolean = entityObject.enabled

local _entityProtectedValue: number = entitySelf.protectedValue

local _entityPrivateValue: string = entitySelf.privateValue

local _entityKind: string = entityClass.kind

local _entityClone: EntityObject = entityObject:clone()

local _entityCreated: EntityObject = entityClass.create("entity")

function entityImpl:clone()
	local _self: EntitySelf = self

	return any()
end

function entityImpl:getSelf()
	local _self: EntitySelf = self

	return self
end

function entityImpl:protectedMethod(value)
	local _self: EntitySelf = self
	local _value: string = value

	return value
end

function entityImpl:privateMethod()
	local _self: EntitySelf = self
	local _private: string = self.privateValue

	return _private
end

entityImpl.kind = "entity"

entityImpl.create = function(name)
	local _name: string = name

	return any()
end

-- Check: Child Inheritance
-- Pass condition: this section type-checks without diagnostics.
type PlayerSpec = {
	username: Var<string>,
	score: Var<number>,
}

type Player = Class<PlayerSpec, Entity>

type PlayerObject = ObjectOf<Player>
type PlayerSelf = SelfOf<Player>
type PlayerClass = ClassOf<Player>
type PlayerImpl = ImplOf<Player>

local playerObject: PlayerObject = any()
local playerSelf: PlayerSelf = any()
local playerClass: PlayerClass = any()
local playerImpl: PlayerImpl = any()

local _playerUsername: string = playerObject.username

local _playerScore: number = playerObject.score

local _playerInheritedId: string = playerObject.id

local _playerInheritedEnabled: boolean = playerObject.enabled

playerObject.id = "player"
playerObject.enabled = true

local _playerProtectedValue: number = playerSelf.protectedValue

playerSelf.protectedValue = 100

local _playerProtectedMethod: string = playerSelf:protectedMethod("hello")

local _playerKind: string = playerClass.kind

local inheritedPlayerConstructor: PlayerObject = playerClass.new("player")

local _constructedUsername: string = inheritedPlayerConstructor.username

local _constructedScore: number = inheritedPlayerConstructor.score

local _constructedInheritedId: string = inheritedPlayerConstructor.id

local inheritedCreatedPlayer: PlayerObject = playerClass.create("player")

local _createdUsername: string = inheritedCreatedPlayer.username

-- Check: Super Reference Rebinding
-- Pass condition: this section type-checks without diagnostics.
local clonedPlayer: PlayerObject = playerObject:clone()

local _clonedPlayerUsername: string = clonedPlayer.username

local _clonedPlayerScore: number = clonedPlayer.score

local playerParent: PlayerObject? = playerObject.parent

if playerParent then
	local _parentUsername: string = playerParent.username

	local _parentScore: number = playerParent.score
end

playerObject.parent = clonedPlayer
playerObject.parent = nil

local playerSelfResult: PlayerSelf = playerSelf:getSelf()

local _selfResultUsername: string = playerSelfResult.username

local _selfResultProtected: number = playerSelfResult.protectedValue

-- Check: Inherited Implementation
-- Pass condition: this section type-checks without diagnostics.
function playerImpl:clone()
	local _self: PlayerSelf = self
	local _username: string = self.username
	local _id: string = self.id
	local _protected: number = self.protectedValue

	return any()
end

function playerImpl:getSelf()
	local _self: PlayerSelf = self

	return self
end

function playerImpl:protectedMethod(value)
	local _self: PlayerSelf = self
	local _value: string = value
	local _username: string = self.username
	local _protected: number = self.protectedValue

	return value
end

playerImpl.kind = "player"

playerImpl.create = function(name)
	local _name: string = name

	return any()
end
