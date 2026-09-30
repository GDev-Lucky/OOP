--!strict

-- Test: Interface composition and reference rebinding
-- Result: type-checks
-- Pass condition: all checks in this file type-check without diagnostics.

local oop = require("../../src/types")

type Class<T, A...> = oop.Class<T, A...>
type Interface<T> = oop.Interface<T>
type Protected<T> = oop.Protected<T>
type Private<T> = oop.Private<T>
type Static<T> = oop.Static<T>
type Field<T> = oop.Field<T>
type Var<T> = oop.Var<T>
type Immut<T> = oop.Immut<T>
type Object = oop.Object
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

-- Check: Interfaces
-- Pass condition: this section type-checks without diagnostics.
type ServiceInterface = Interface<{
	name: Var<string>,

	execute: (number) -> string,

	parse: Field<(string) -> number>,

	version: Static<string>,

	formatVersion: Static<(number) -> string>,

	protectedState: Protected<Var<number>>,

	protectedMethod: Protected<(number) -> number>,

	privateState: Private<Var<boolean>>,

	privateMethod: Private<() -> boolean>,
}>

type ReferenceInterface = Interface<{
	parent: Var<Object?>,

	clone: () -> Object,

	nested: {
		owner: Object,
	},
}>

type SettingsInterface = Interface<{
	settings: Immut<{
		enabled: boolean,

		nested: {
			value: number,
		},
	}>,
}>

type ServiceSpec = {
	serviceOnly: string,
}

type Service = Class<ServiceSpec, ServiceInterface, ReferenceInterface, SettingsInterface>

type ServiceObject = ObjectOf<Service>
type ServiceSelf = SelfOf<Service>
type ServiceClass = ClassOf<Service>
type ServiceImpl = ImplOf<Service>

local serviceObject: ServiceObject = any()
local serviceSelf: ServiceSelf = any()
local serviceClass: ServiceClass = any()
local serviceImpl: ServiceImpl = any()

local _serviceOnly: string = serviceObject.serviceOnly

local _serviceName: string = serviceObject.name

serviceObject.name = "changed"

local _serviceExecute: string = serviceObject:execute(123)

local _serviceExecuteDot: string = serviceObject.execute(serviceObject, 123)

local _serviceParsed: number = serviceObject.parse("123")

local _serviceVersion: string = serviceClass.version

local _formattedVersion: string = serviceClass.formatVersion(123)

local _serviceProtectedState: number = serviceSelf.protectedState

serviceSelf.protectedState = 10

local _serviceProtectedMethod: number = serviceSelf:protectedMethod(10)

local _serviceSettingsEnabled: boolean = serviceObject.settings.enabled

local _serviceSettingsNestedValue: number = serviceObject.settings.nested.value

function serviceImpl:execute(value)
	local _self: ServiceSelf = self
	local _value: number = value
	local _protected: number = self.protectedState
	local _serviceOnly: string = self.serviceOnly

	return tostring(value)
end

serviceImpl.parse = function(value)
	local _value: string = value

	return tonumber(value) or 0
end

function serviceImpl:protectedMethod(value)
	local _self: ServiceSelf = self
	local _value: number = value
	local _state: number = self.protectedState

	return value + _state
end

serviceImpl.version = "1.0.0"

serviceImpl.formatVersion = function(value)
	local _value: number = value

	return tostring(value)
end

-- Check: Interface Reference Rebinding
-- Pass condition: this section type-checks without diagnostics.
local serviceClone: ServiceObject = serviceObject:clone()

local _serviceCloneOnly: string = serviceClone.serviceOnly

local serviceParent: ServiceObject? = serviceObject.parent

if serviceParent then
	local _serviceParentOnly: string = serviceParent.serviceOnly
end

serviceObject.parent = serviceClone
serviceObject.parent = nil

local serviceOwner: ServiceObject = serviceObject.nested.owner

local _serviceOwnerOnly: string = serviceOwner.serviceOnly

function serviceImpl:clone()
	local _self: ServiceSelf = self

	return any()
end
