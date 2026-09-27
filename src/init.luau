--!strict

local Types = require("@self/types")

type ToImpl<T> = Types.ToImpl<T>
type ObjectOf<T> = Types.ObjectOf<T>
type ObjectValueOf<T> = Types.ObjectValuesOf<T>
type ClassType = Types.ClassType
type ParentsOf<T> = Types.ParentsOf<T, ClassType>
type ClassOf<T> = Types.ClassOf<T>

type function Inject(func: type, rValue: type): type
	local params = func:parameters().head or {}
	table.insert(params, 1, types.any)
	return types.newfunction({ head = params}, { head = { rValue} }, func:generics())
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
type Object<T> = (any, ObjectValueOf<T>) -> ObjectOf<T>

type Lib<T> = {
	__index: Lib<T>,
	declare: Inject<ParentsOf<T>, Add<ToImpl<T>, Object<T>, Export<T>>>,
	export: Export<T>,
	object: Object<T>,
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
	for _, parent in { ... } do
		for key, property in parent do
			if key == "__index"  then 
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

function Lib.object<T>(self: Lib<T>, value: ObjectValueOf<T>): ObjectOf<T>
	return setmetatable(value, self) :: any
end

return Lib
