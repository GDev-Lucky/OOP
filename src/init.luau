--!strict

local Types = require("@self/types")

-- Public type API: require this module for both the runtime builder and types.
export type Self = Types.Self
export type Object = Types.Object
export type ClassType = Types.ClassType
export type Impl = Types.Impl

export type Class<T, A...> = Types.Class<T, A...>
export type Refine<Base, Spec, Parents...> = Types.Refine<Base, Spec, Parents...>
export type Interface<T> = Types.Interface<T>
export type Trait<T> = Types.Trait<T>
export type Override<T> = Types.Override<T>

export type View<T, K> = Types.View<T, K>
export type ViewOf<T, K> = Types.ViewOf<T, K>
export type ToClass<T> = Types.ToClass<T>
export type ToObject<T> = Types.ToObject<T>
export type ToSelf<T> = Types.ToSelf<T>
export type ToImpl<T> = Types.ToImpl<T>
export type ToSpec<T> = Types.ToSpec<T>
export type ToBase<T> = Types.ToBase<T>
export type ParentsOf<T, R, B = false> = Types.ParentsOf<T, R, B>

export type ClassOf<T> = Types.ClassOf<T>
export type ObjectOf<T> = Types.ObjectOf<T>
export type SelfOf<T> = Types.SelfOf<T>
export type ImplOf<T> = Types.ImplOf<T>
export type SpecOf<T> = Types.SpecOf<T>
export type BaseOf<T> = Types.BaseOf<T>

export type Public<T> = Types.Public<T>
export type Protected<T> = Types.Protected<T>
export type Private<T> = Types.Private<T>
export type Static<T> = Types.Static<T>
export type Method<T> = Types.Method<T>
export type Field<T> = Types.Field<T>
export type Const<T> = Types.Const<T>
export type Var<T> = Types.Var<T>
export type Mut<T> = Types.Mut<T>
export type Immut<T> = Types.Immut<T>
export type Constructor<T> = Types.Constructor<T>
export type ObjectValuesOf<T> = Types.ObjectValuesOf<T>
export type AssertObjectValuesOf<T, V> = Types.AssertObjectValuesOf<T, V>

type function Inject(func: type, rValue: type): type
	local params = func:parameters().head or {}
	table.insert(params, 1, types.any)
	return types.newfunction({ head = params }, { head = { rValue } }, func:generics())
end

type function Add(inter: type, object: type, export: type)
	local objectKey = types.singleton("object")
	local exportKey = types.singleton("export")
	local tbl = inter:components()[1]

	if not tbl:is("table") then
		error("Invalid class type passed into, Class.new<<ClassType>>()")
	end
	if tbl:readproperty(objectKey) then
		error("Spec defines :object(), use Class.object(Impl, object)")
	end
	if tbl:readproperty(exportKey) then
		error("Spec defines :export(), use Class.export(Impl)")
	end
	tbl:setreadproperty(objectKey, object)
	tbl:setreadproperty(exportKey, export)
	return tbl
end

type Export<T> = (any) -> ClassOf<T>
type LibObject<T> = (any, ObjectValuesOf<T>) -> ObjectOf<T>

type Lib<T> = {
	__index: Lib<T>,
	declare: Inject<ParentsOf<T, ClassType, true>, Add<ToImpl<T>, LibObject<T>, Export<T>>>,
	export: Export<T>,
	object: LibObject<T>,
}

local Lib = {}
Lib.__index = Lib

function Lib.new<T>(): Lib<T>
	local self = {}
	self.__index = self

	return setmetatable(self, Lib) :: any
end

function Lib.declare<T>(self: Lib<T>, ...): ToImpl<T>
	local class: any = self
	local parents = { ... }

	for i = #parents, 1, -1 do
		local parent = parents[i]
		for key, property in parent do
			if key == "__index" then
				continue
			end
			class[key] = property
		end
	end

	return class
end

function Lib.export<T>(self: Lib<T>): Types.ClassOf<T>
	return self :: any
end

function Lib.object<T>(self: Lib<T>, value: ObjectValuesOf<T>): ObjectOf<T>
	return setmetatable(value, self) :: any
end

return Lib
