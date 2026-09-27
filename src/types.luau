--!strict

--[[

    OOP-FRAMEWORK

    FULL TYPE-SIDE LOGIC + API

    ----------------------

    NAME GUIDE:

    SPEC -> USER DEFINED TYPE

    OBJECT -> RUNTIME INSTANCE OF THE CLASS (RETURN TYPE OF CONSTRUCTOR)

    SELF -> REFERENCE TO THE OBJECT USED WHILE DECLARING CLASS RUNTIME IMPLEMENTATION

    IMPL -> REFERENCE TO THE TABLE IN WHICH USER DECLARES CLASS

    CLASS -> PUBLICLY EXPORTER VERSION OF IMPL

    BUNDlE -> A TYPE CREATED USING A & (A | B) = A WHERE A IS A SELECTED TYPE WHILE B IS HIDDEN METADATA

    METADATA -> A COMPILED OUTPUT THAT EXTRACTORS AND VIEWS CAN USE

    EXTRACTOR -> A HELPER TO EXTRACT A SPECFIC VERSION OF THE CLASS FROM BUNDLE (EX: ObjectOF<>)

    VIEW -> A VERSION OF THE BUNDLE WITH SPECFIC VERSION OF THE CLASS AS PRIMARY (EX: ToObject<>)

    REFERENCE -> A PLACEHOLDER TYPE THAT ALLOWS CLASSES TO REPRESENT ITSELF AND IT VARIENTS IN SPEC COMPILER AUTOMATICALLY RESOLVES

    THESE TO FINALIZED TYPE OF THE VARIENT

    MODIFIER -> A KEYWORD / TYPE<> THAT WRAPS THE ORGINAL VALUE IN SPEC IT TELL THE COMPILER HOW TO MODIFY THE VALUE

    SUPERCLASS -> A CLASS THAT SOME OTHER CLASS INHERITS FROM

    INTERFACE -> A PURE TYPE ONLY STRUCTURE THAT ENFORCES CLASSES TO IMPLEMENT IT IF THEY ADD IT AS THIER PARENT

    TRAIT -> WORK SIMILAR TO INTERFACES BUT CONTAIN RUNTIME LOGIC THAT IS INJECTED INTO THE CLASS THAT IMPLEMENTS IT

    PARENTS -> SUPER CLASS, TRAITS, INTERFACES

    CHILD -> CLASS THAT INHERITS FROM PARENTS

    ----------------------

    ----------------------

    COMPILATION PIPELINE:

    CLASS SPEC + PARENTS ->

    COMPILE METADATA ->

    MERGE PARENT METADATA ->

    DETECT COLLISIONS ->

    BUILD ALL VIEWS ->

    RESOLVE REFERENCES ->

    ATTACH HIDDEN BUILD METADATA ->

    RETURN OBJECT TYPE + HIDDEN META DATA

    ----------------------

]]

type Config = {

	modifierKey: "__class_modifier",

	valueKey: "__class_value",

	referenceKey: "__class_reference",

	referenceGenericsKey: "__class_reference_generics",

	genericsKey: "___generics",

	bundleKey: "__class_bundle",

	bundleValue: "__class_bundle_v1",

	parentsKey: "__class_parents",

	metadataKey: "__class_metadata",

	kindKey: "__class_kind",

	collisionsKey: "__class_collisions",

	overrideKey: "__class_override",

	entryValueKey: "__class_entry_value",

	entryVisibilityKey: "__class_entry_visibility",

	entryStaticKey: "__class_entry_static",

	entryMethodKey: "__class_entry_method",

	entryConstKey: "__class_entry_const",

	public: "public",

	protected: "protected",

	private: "private",

	static: "static",

	method: "method",

	field: "field",

	const: "const",

	var: "var",

	mut: "mut",

	immut: "immut",

	constructor: "constructor",

	self: "self",

	object: "object",

	class: "class",

	impl: "impl",

	spec: "spec",

	classKind: "class",

	interfaceKind: "interface",

	traitKind: "trait",
}

type function ReadConf(config: type, name: string): type
	local value = config:readproperty(types.singleton(name))

	assert(value, "invalid config, cannot find" .. name)

	return value
end

type function Reference(target: type, generics: type, config: type): type
	local referenceKey = ReadConf(config, "referenceKey")
	local referenceGenericsKey = ReadConf(config, "referenceGenericsKey")

	assert(generics:is("function"), "Reference generics must be a function type")

	local result = types.newtable()
	result:setproperty(referenceKey, target)
	result:setproperty(referenceGenericsKey, generics)

	return result
end

type function Modifier(modifier: type, value: type, config: type): type
	local modifierKey = ReadConf(config, "modifierKey")

	local valueKey = ReadConf(config, "valueKey")

	local wrapper = types.newtable()

	wrapper:setproperty(modifierKey, modifier)

	wrapper:setproperty(valueKey, value)

	return wrapper
end

type function Pack(primary: type, bundle: type): type
	return types.intersectionof(primary, types.unionof(primary, bundle))
end

type function FindBundle(value: type, config: type): type
	local bundleKey = ReadConf(config, "bundleKey")

	local bundleValue = ReadConf(config, "bundleValue")

	local visited: { [type]: boolean } = {}

	local function find(source: type): type?
		if visited[source] then
			return nil
		end

		visited[source] = true

		if source:is("table") and source:readproperty(bundleKey) == bundleValue then
			return source
		end

		if source:is("union") or source:is("intersection") then
			for _, component in source:components() do
				local found = find(component)

				if found then
					return found
				end
			end
		end

		return nil
	end

	return find(value) or types.never
end

type function HasProperties(value: type): type
	if not value:is("table") then
		return types.singleton(false)
	end

	for _ in value:properties() do
		return types.singleton(true)
	end

	return types.singleton(false)
end

type function ValidateBundle(value: type, config: type): type
	local bundle = FindBundle(value, config)

	assert(bundle ~= types.never, "Class bundle not found")

	assert(bundle:is("table"))

	local kindKey = ReadConf(config, "kindKey")

	local collisionsKey = ReadConf(config, "collisionsKey")

	local overrideKey = ReadConf(config, "overrideKey")

	local classKind = ReadConf(config, "classKind")

	if bundle:readproperty(kindKey) ~= classKind then
		return bundle
	end

	local collisions = bundle:readproperty(collisionsKey)

	local overridden = bundle:readproperty(overrideKey) == types.singleton(true)

	if collisions and collisions:is("table") and not overridden then
		local names: { string } = {}

		for name in collisions:properties() do
			if name:is("singleton") then
				table.insert(names, tostring(name:value()))
			end
		end

		if #names > 0 then
			table.sort(names)

			error(
				"Class inheritance collision: "
					.. table.concat(names, ", ")
					.. ". Wrap the class in Override<...> to resolve collisions by composition order"
			)
		end
	end

	return bundle
end

type function Extract(value: type, target: type, config: type): type
	local bundle = ValidateBundle(value, config)

	assert(bundle:is("table"))

	local result = bundle:readproperty(target)

	assert(result, "Return type not found in class bundle")

	return result
end

type function MakeImmutable(value: type, config: type): type
	if not value:is("table") then
		error("Immut<T> requires T to be a table")
	end

	local referenceKey = ReadConf(config, "referenceKey")

	local cache: { [type]: type } = {}

	local function freeze(source: type): type
		local cached = cache[source]

		if cached then
			return cached
		end

		local tag = source.tag

		if tag == "table" then
			if source:readproperty(referenceKey) then
				return source
			end

			local sourceIndexer = source:indexer()

			local indexer = nil

			if sourceIndexer then
				indexer = {

					index = freeze(sourceIndexer.index),

					readresult = freeze(sourceIndexer.readresult),

					writeresult = types.never,
				}
			end

			local result = types.newtable(nil, indexer)

			cache[source] = result

			for key, property in source:properties() do
				if property.read then
					result:setreadproperty(key, freeze(property.read))
				end
			end

			local metatable = source:metatable()

			if metatable then
				result:setmetatable(freeze(metatable))
			end

			return result
		end

		if tag == "union" or tag == "intersection" then
			local components: { type } = {}

			for _, component in source:components() do
				table.insert(components, freeze(component))
			end

			local result: type

			if tag == "union" then
				result = types.unionof(unpack(components))
			else
				result = types.intersectionof(unpack(components))
			end

			cache[source] = result

			return result
		end

		if tag == "negation" then
			local result = types.negationof(freeze(source:inner()))

			cache[source] = result

			return result
		end

		cache[source] = source

		return source
	end

	return freeze(value)
end

type function CompileMetadata(spec: type, kind: type, config: type): type
	if not spec:is("table") then
		error("Class must be of type table")
	end

	local modifierKey = ReadConf(config, "modifierKey")

	local valueKey = ReadConf(config, "valueKey")

	local entryValueKey = ReadConf(config, "entryValueKey")

	local entryVisibilityKey = ReadConf(config, "entryVisibilityKey")

	local entryStaticKey = ReadConf(config, "entryStaticKey")

	local entryMethodKey = ReadConf(config, "entryMethodKey")

	local entryConstKey = ReadConf(config, "entryConstKey")

	local publicKey = ReadConf(config, "public")

	local protectedKey = ReadConf(config, "protected")

	local privateKey = ReadConf(config, "private")

	local staticKey = ReadConf(config, "static")

	local methodKey = ReadConf(config, "method")

	local fieldKey = ReadConf(config, "field")

	local constKey = ReadConf(config, "const")

	local varKey = ReadConf(config, "var")

	local mutKey = ReadConf(config, "mut")

	local immutKey = ReadConf(config, "immut")

	local constructorKey = ReadConf(config, "constructor")
	local genericsKey = ReadConf(config, "genericsKey")

	local objectKey = ReadConf(config, "object")

	local classKind = ReadConf(config, "classKind")

	local metadata = types.newtable()

	local kindName = tostring(kind:value())

	local function compileMember(propertyType: type): type
		local chain: { type } = {}

		local value = propertyType

		while value:is("table") do
			local modifier = value:readproperty(modifierKey)

			if not modifier then
				break
			end

			assert(modifier:is("singleton"), "Modifier must be a singleton")

			local inner = value:readproperty(valueKey)

			assert(inner, "Modifier wrapper has no value")

			table.insert(chain, modifier)

			value = inner
		end

		local baseValue = value

		local currentValue = baseValue

		local isStatic = false

		local isMethod = true

		local isConst = true

		local visibility = publicKey

		for index = #chain, 1, -1 do
			local modifier = chain[index]

			if modifier == publicKey then
				visibility = publicKey
			elseif modifier == protectedKey then
				visibility = protectedKey
			elseif modifier == privateKey then
				visibility = privateKey
			elseif modifier == staticKey then
				isStatic = true

				isMethod = false
			elseif modifier == methodKey then
				isMethod = true
			elseif modifier == fieldKey then
				isMethod = false
			elseif modifier == constKey then
				isConst = true
			elseif modifier == varKey then
				isConst = false
			elseif modifier == mutKey then
				if baseValue:is("table") then
					currentValue = baseValue
				end
			elseif modifier == immutKey then
				currentValue = MakeImmutable(currentValue, config)
			elseif modifier == constructorKey then
				if kind ~= classKind then
					error(kindName .. " cannot declare Constructor<T>")
				end

				if not currentValue:is("function") then
					error("Constructor<T> requires T to be a function")
				end

				currentValue = types.newfunction(currentValue:parameters(), {

					head = { Reference(objectKey, types.newfunction({ head = {} }, { head = {} }), config) },
				}, currentValue:generics())

				isStatic = true

				isMethod = false
			else
				error("Unknown class modifier: " .. tostring(modifier))
			end
		end

		local entry = types.newtable()

		entry:setreadproperty(entryValueKey, currentValue)

		entry:setreadproperty(entryVisibilityKey, visibility)

		entry:setreadproperty(entryStaticKey, types.singleton(isStatic))

		entry:setreadproperty(entryMethodKey, types.singleton(isMethod))

		entry:setreadproperty(entryConstKey, types.singleton(isConst))

		return entry
	end

	for name, property in spec:properties() do
		if name == genericsKey then
			continue
		end

		local propertyType = property.read or property.write

		assert(propertyType, "property type must exist")

		metadata:setreadproperty(name, compileMember(propertyType))
	end

	return metadata
end

type function MergeMetadata(localMetadata: type, config: type, sources: type)
	assert(localMetadata:is("table"))

	local kindKey = ReadConf(config, "kindKey")

	local metadataKey = ReadConf(config, "metadataKey")

	local collisionsKey = ReadConf(config, "collisionsKey")

	local overrideKey = ReadConf(config, "overrideKey")

	local entryVisibilityKey = ReadConf(config, "entryVisibilityKey")

	local privateKey = ReadConf(config, "private")

	local classKind = ReadConf(config, "classKind")

	local interfaceKind = ReadConf(config, "interfaceKind")

	local traitKind = ReadConf(config, "traitKind")

	assert(sources:is("function"), "Class composition source pack must be a function type")

	local sourceReturns = sources:returns()

	if sourceReturns.tail then
		error("Class composition source pack must be concrete")
	end

	local sourceList = sourceReturns.head or {}

	local merged = types.newtable()

	local collisions = types.newtable()

	local seen: { [string]: boolean } = {}

	local superCount = 0

	local function validateSource(bundle: type)
		local sourceKind = bundle:readproperty(kindKey)

		assert(sourceKind, "Composition source kind not found")

		if sourceKind ~= classKind and sourceKind ~= interfaceKind and sourceKind ~= traitKind then
			error("Invalid composition source")
		end

		if sourceKind == classKind then
			superCount += 1

			if superCount > 1 then
				error("Class<T, A...> can contain only one super class")
			end
		end

		local sourceCollisions = bundle:readproperty(collisionsKey)

		local sourceOverridden = bundle:readproperty(overrideKey) == types.singleton(true)

		if sourceCollisions and sourceCollisions:is("table") and not sourceOverridden then
			local names: { string } = {}

			for name in sourceCollisions:properties() do
				if name:is("singleton") then
					table.insert(names, tostring(name:value()))
				end
			end

			if #names > 0 then
				table.sort(names)

				error("Composition source contains unresolved inheritance collisions: " .. table.concat(names, ", "))
			end
		end
	end

	for sourceIndex = 1, #sourceList do
		local source = sourceList[sourceIndex]

		local bundle = FindBundle(source, config)

		if bundle == types.never then
			error("Class composition arguments must be Class<...>, Interface<...>, or Trait<...> bundles")
		end

		assert(bundle:is("table"))

		validateSource(bundle)

		local sourceMetadata = bundle:readproperty(metadataKey)

		assert(sourceMetadata and sourceMetadata:is("table"), "Composition source metadata not found")

		for name, property in sourceMetadata:properties() do
			local entry = property.read or property.write

			assert(entry and entry:is("table"), "Invalid composition metadata entry")

			local visibility = entry:readproperty(entryVisibilityKey)

			assert(visibility and visibility:is("singleton"), "Invalid composition visibility")

			if visibility == privateKey then
				continue
			end

			local memberName = tostring(name:value())

			if seen[memberName] then
				collisions:setreadproperty(name, types.singleton(true))

				continue
			end

			seen[memberName] = true

			merged:setreadproperty(name, entry)
		end
	end

	for name, property in localMetadata:properties() do
		local entry = property.read or property.write

		assert(entry, "Invalid local metadata entry")

		merged:setreadproperty(name, entry)
	end

	local result = types.newtable()

	result:setreadproperty(metadataKey, merged)

	result:setreadproperty(collisionsKey, collisions)

	return result
end

type function BuildViews(metadata: type, kind: type, config: type, genericCarrier: type)
	assert(metadata:is("table"))
	assert(genericCarrier:is("function"), "Class generic carrier must be a function type")

	local referenceKey = ReadConf(config, "referenceKey")
	local referenceGenericsKey = ReadConf(config, "referenceGenericsKey")

	local entryValueKey = ReadConf(config, "entryValueKey")
	local entryVisibilityKey = ReadConf(config, "entryVisibilityKey")
	local entryStaticKey = ReadConf(config, "entryStaticKey")
	local entryMethodKey = ReadConf(config, "entryMethodKey")
	local entryConstKey = ReadConf(config, "entryConstKey")

	local publicKey = ReadConf(config, "public")

	local selfKey = ReadConf(config, "self")
	local objectKey = ReadConf(config, "object")
	local classKey = ReadConf(config, "class")
	local implKey = ReadConf(config, "impl")

	local classKind = ReadConf(config, "classKind")
	local traitKind = ReadConf(config, "traitKind")

	if kind ~= classKind and kind ~= traitKind then
		error("Only classes and traits have compiled views")
	end

	local rawSelf = types.newtable()
	local rawObject = if kind == classKind then types.newtable() else nil
	local rawClass = types.newtable()
	local rawImpl = types.newtable()

	local emptyGenerics = types.newfunction({
		head = {},
	}, {
		head = {},
	})

	local selfReference = Reference(selfKey, emptyGenerics, config)
	local objectReference = Reference(objectKey, emptyGenerics, config)
	local classReference = Reference(classKey, emptyGenerics, config)

	local genericReturns = genericCarrier:returns()

	if genericReturns.tail then
		error("___generics does not support variadic generic packs")
	end

	local declaredGenerics = genericReturns.head or {}

	local genericDependencyCache: { [type]: boolean } = {}
	local genericDependencyActive: { [type]: boolean } = {}

	local function usesDeclaredGeneric(source: type): boolean
		local cached = genericDependencyCache[source]

		if cached ~= nil then
			return cached
		end

		for _, generic in declaredGenerics do
			if source == generic then
				genericDependencyCache[source] = true
				return true
			end
		end

		if genericDependencyActive[source] then
			return false
		end

		genericDependencyActive[source] = true

		local result = false
		local tag = source.tag

		if tag == "table" then
			for _, property in source:properties() do
				if property.read and usesDeclaredGeneric(property.read) then
					result = true
					break
				end

				if property.write and usesDeclaredGeneric(property.write) then
					result = true
					break
				end
			end

			if not result then
				local indexer = source:indexer()

				if indexer then
					result = usesDeclaredGeneric(indexer.index)
						or usesDeclaredGeneric(indexer.readresult)
						or usesDeclaredGeneric(indexer.writeresult)
				end
			end

			if not result then
				local metatable = source:metatable()

				if metatable then
					result = usesDeclaredGeneric(metatable)
				end
			end
		elseif tag == "function" then
			local parameters = source:parameters()
			local returns = source:returns()

			for _, parameter in parameters.head or {} do
				if usesDeclaredGeneric(parameter) then
					result = true
					break
				end
			end

			if not result and parameters.tail then
				result = usesDeclaredGeneric(parameters.tail)
			end

			if not result then
				for _, returnType in returns.head or {} do
					if usesDeclaredGeneric(returnType) then
						result = true
						break
					end
				end
			end

			if not result and returns.tail then
				result = usesDeclaredGeneric(returns.tail)
			end
		elseif tag == "union" or tag == "intersection" then
			for _, component in source:components() do
				if usesDeclaredGeneric(component) then
					result = true
					break
				end
			end
		elseif tag == "negation" then
			result = usesDeclaredGeneric(source:inner())
		end

		genericDependencyActive[source] = nil
		genericDependencyCache[source] = result

		return result
	end

	local function injectFirst(func: type, argument: type): type
		assert(func:is("function"), "injectFirst requires a function")

		local parameters = func:parameters()
		local head: { type } = { argument }

		for _, parameter in parameters.head or {} do
			table.insert(head, parameter)
		end

		return types.newfunction({
			head = head,
			tail = parameters.tail,
		}, func:returns(), func:generics())
	end

	local function emit(target: type, reference: type, name: type, value: type, isMethod: boolean, isConst: boolean)
		if isMethod and value:is("function") then
			value = injectFirst(value, reference)
		end

		if isConst then
			target:setreadproperty(name, value)
		else
			target:setproperty(name, value)
		end
	end

	for name, property in metadata:properties() do
		local entry = property.read or property.write
		assert(entry and entry:is("table"), "Invalid metadata entry")

		local value = entry:readproperty(entryValueKey)
		local visibility = entry:readproperty(entryVisibilityKey)
		local staticValue = entry:readproperty(entryStaticKey)
		local methodValue = entry:readproperty(entryMethodKey)
		local constValue = entry:readproperty(entryConstKey)

		assert(value, "Metadata value not found")
		assert(visibility and visibility:is("singleton"), "Metadata visibility not found")
		assert(staticValue and staticValue:is("singleton"), "Metadata static state not found")
		assert(methodValue and methodValue:is("singleton"), "Metadata method state not found")
		assert(constValue and constValue:is("singleton"), "Metadata const state not found")

		local isPublic = visibility == publicKey
		local isStatic = staticValue:value() == true
		local isMethod = methodValue:value() == true
		local isConst = constValue:value() == true
		local isFunction = value:is("function")

		if isStatic then
			if isPublic then
				emit(rawClass, classReference, name, value, isMethod, isConst)
			end

			emit(rawImpl, selfReference, name, value, isMethod, false)
		else
			emit(rawSelf, selfReference, name, value, isMethod, isConst)

			if isPublic and rawObject then
				emit(rawObject, objectReference, name, value, isMethod, isConst)
			end

			if isFunction then
				emit(rawImpl, selfReference, name, value, isMethod, false)
			end
		end
	end

	local contexts: { any } = {}

	local function sameArguments(a: { type }, b: { type }): boolean
		if #a ~= #b then
			return false
		end

		for index = 1, #a do
			if a[index] ~= b[index] then
				return false
			end
		end

		return true
	end

	local function getContext(arguments: { type })
		for _, context in contexts do
			if sameArguments(context.arguments, arguments) then
				return context
			end
		end

		if #arguments ~= #declaredGenerics then
			error(
				"Class reference generic count mismatch: expected "
					.. tostring(#declaredGenerics)
					.. ", got "
					.. tostring(#arguments)
			)
		end

		if #contexts >= 512 then
			error(
				"Class generic specialization graph exceeded 512 contexts; "
					.. "reference specialization may be recursively expanding"
			)
		end

		local context: any = {
			arguments = arguments,

			cache = {} :: { [type]: type },
			resolving = {} :: { [type]: boolean },

			complete = false,

			self = types.newtable(),
			object = if rawObject then types.newtable() else nil,
			class = types.newtable(),
			impl = types.newtable(),
		}

		context.cache[rawSelf] = context.self
		context.cache[rawClass] = context.class
		context.cache[rawImpl] = context.impl

		if rawObject then
			context.cache[rawObject] = context.object
		end

		table.insert(contexts, context)

		return context
	end

	local function rawTarget(referenceValue: type): type?
		if referenceValue == selfKey then
			return rawSelf
		elseif referenceValue == objectKey then
			if not rawObject then
				error("Object references are not available in Trait<...>")
			end

			return rawObject
		elseif referenceValue == classKey then
			return rawClass
		elseif referenceValue == implKey then
			return rawImpl
		end

		return nil
	end

	local function contextTarget(context: any, referenceValue: type): type?
		if referenceValue == selfKey then
			return context.self
		elseif referenceValue == objectKey then
			if not context.object then
				error("Object references are not available in Trait<...>")
			end

			return context.object
		elseif referenceValue == classKey then
			return context.class
		elseif referenceValue == implKey then
			return context.impl
		end

		return nil
	end

	local function resolve(source: type, context: any): type
		for index, generic in declaredGenerics do
			if source == generic then
				return context.arguments[index] or source
			end
		end

		local cached = context.cache[source]

		if cached then
			return cached
		end

		local tag = source.tag

		if tag == "table" then
			local referenceValue = source:readproperty(referenceKey)

			if referenceValue then
				local targetSource = rawTarget(referenceValue)

				if targetSource then
					local referenceGenerics = source:readproperty(referenceGenericsKey)

					assert(
						referenceGenerics and referenceGenerics:is("function"),
						"Class reference generic carrier not found"
					)

					local referenceReturns = referenceGenerics:returns()

					if referenceReturns.tail then
						error("Class references do not support variadic generic packs")
					end

					local referenceArguments = referenceReturns.head or {}

					local targetContext = context

					if #referenceArguments > 0 then
						if #declaredGenerics == 0 then
							error("Reference specialization requires ___generics: Generic<...>")
						end

						if #referenceArguments ~= #declaredGenerics then
							error(
								"Class reference generic count mismatch: expected "
									.. tostring(#declaredGenerics)
									.. ", got "
									.. tostring(#referenceArguments)
							)
						end

						local resolvedArguments: { type } = {}

						for _, argument in referenceArguments do
							if usesDeclaredGeneric(argument) then
								table.insert(resolvedArguments, resolve(argument, context))
							else
								table.insert(resolvedArguments, argument)
							end
						end

						targetContext = getContext(resolvedArguments)
					end

					local target = contextTarget(targetContext, referenceValue)

					assert(target, "Class reference target not found")

					context.cache[source] = target

					return target
				end
			end

			local sourceIndexer = source:indexer()

			if not sourceIndexer then
				local result = types.newtable()

				context.cache[source] = result
				context.resolving[source] = true

				for key, property in source:properties() do
					if property.read and property.write and property.read == property.write then
						result:setproperty(key, resolve(property.read, context))
					else
						if property.read then
							result:setreadproperty(key, resolve(property.read, context))
						end

						if property.write then
							result:setwriteproperty(key, resolve(property.write, context))
						end
					end
				end

				local metatable = source:metatable()

				if metatable then
					result:setmetatable(resolve(metatable, context))
				end

				context.resolving[source] = nil

				return result
			end

			if context.resolving[source] then
				error("Class resolver cannot currently resolve a recursive table whose cycle passes through an indexer")
			end

			context.resolving[source] = true

			local properties: { [type]: type } | {
				[type]: {
					read: type?,
					write: type?,
				},
			} = {}

			for key, property in source:properties() do
				if property.read and property.write and property.read == property.write then
					properties[key] = resolve(property.read, context)
				else
					properties[key] = {
						read = if property.read then resolve(property.read, context) else nil,

						write = if property.write then resolve(property.write, context) else nil,
					}
				end
			end

			local metatable = source:metatable()

			local result = types.newtable(properties, {
				index = resolve(sourceIndexer.index, context),

				readresult = resolve(sourceIndexer.readresult, context),

				writeresult = resolve(sourceIndexer.writeresult, context),
			}, if metatable then resolve(metatable, context) else nil)

			context.cache[source] = result
			context.resolving[source] = nil

			return result
		end

		if tag == "function" then
			local result = types.newfunction({
				head = {},
			}, {
				head = {},
			}, source:generics())

			context.cache[source] = result

			local parameters = source:parameters()
			local returns = source:returns()

			local parameterHead: { type } = {}
			local returnHead: { type } = {}

			for _, parameter in parameters.head or {} do
				table.insert(parameterHead, resolve(parameter, context))
			end

			for _, returnType in returns.head or {} do
				table.insert(returnHead, resolve(returnType, context))
			end

			result:setparameters(parameterHead, if parameters.tail then resolve(parameters.tail, context) else nil)

			result:setreturns(returnHead, if returns.tail then resolve(returns.tail, context) else nil)

			return result
		end

		if tag == "union" or tag == "intersection" then
			local components: { type } = {}

			for _, component in source:components() do
				table.insert(components, resolve(component, context))
			end

			local result: type

			if tag == "union" then
				result = types.unionof(unpack(components))
			else
				result = types.intersectionof(unpack(components))
			end

			context.cache[source] = result

			return result
		end

		if tag == "negation" then
			local result = types.negationof(resolve(source:inner(), context))

			context.cache[source] = result

			return result
		end

		context.cache[source] = source

		return source
	end

	local function populateRoot(source: type, result: type, context: any)
		for key, property in source:properties() do
			if property.read and property.write and property.read == property.write then
				result:setproperty(key, resolve(property.read, context))
			else
				if property.read then
					result:setreadproperty(key, resolve(property.read, context))
				end

				if property.write then
					result:setwriteproperty(key, resolve(property.write, context))
				end
			end
		end

		local metatable = source:metatable()

		if metatable then
			result:setmetatable(resolve(metatable, context))
		end
	end

	local function populateContext(context: any)
		if context.complete then
			return
		end

		populateRoot(rawSelf, context.self, context)

		populateRoot(rawClass, context.class, context)

		populateRoot(rawImpl, context.impl, context)

		if rawObject then
			populateRoot(rawObject, context.object, context)
		end

		context.complete = true
	end

	local baseContext = getContext(declaredGenerics)

	local contextIndex = 1

	while contextIndex <= #contexts do
		populateContext(contexts[contextIndex])

		contextIndex += 1
	end

	local result = types.newtable()

	result:setreadproperty(selfKey, baseContext.self)

	result:setreadproperty(classKey, baseContext.class)

	result:setreadproperty(implKey, baseContext.impl)

	if rawObject then
		result:setreadproperty(objectKey, baseContext.object)
	end

	return result
end

type function Compile(spec: type, kind: type, config: type, sources: type): type
	local bundleKey = ReadConf(config, "bundleKey")

	local bundleValue = ReadConf(config, "bundleValue")

	local metadataKey = ReadConf(config, "metadataKey")

	local kindKey = ReadConf(config, "kindKey")

	local collisionsKey = ReadConf(config, "collisionsKey")

	local overrideKey = ReadConf(config, "overrideKey")

	local selfKey = ReadConf(config, "self")

	local objectKey = ReadConf(config, "object")

	local classKey = ReadConf(config, "class")

	local implKey = ReadConf(config, "impl")

	local specKey = ReadConf(config, "spec")

	local parentsKey = ReadConf(config, "parentsKey")
	local genericsKey = ReadConf(config, "genericsKey")

	local classKind = ReadConf(config, "classKind")

	local interfaceKind = ReadConf(config, "interfaceKind")

	local traitKind = ReadConf(config, "traitKind")

	if kind ~= classKind and kind ~= interfaceKind and kind ~= traitKind then
		error("Invalid class bundle kind")
	end

	assert(sources:is("function"), "Composition source pack must be a function type")

	local sourceReturns = sources:returns()

	if sourceReturns.tail then
		error("Composition source pack must be concrete")
	end

	if kind ~= classKind and sourceReturns.head and #sourceReturns.head > 0 then
		error("Only Class<T, A...> accepts composition arguments")
	end

	local genericCarrier = spec:readproperty(genericsKey)

	if genericCarrier then
		if not genericCarrier:is("function") then
			error("___generics must be Generic<...>")
		end
	else
		genericCarrier = types.newfunction({
			head = {},
		}, {
			head = {},
		})
	end

	local localMetadata = CompileMetadata(spec, kind, config)

	local metadata = localMetadata

	local collisions = types.newtable()

	if kind == classKind then
		local merged = MergeMetadata(localMetadata, config, sources)

		local mergedMetadata = merged:readproperty(metadataKey)

		local mergedCollisions = merged:readproperty(collisionsKey)

		assert(mergedMetadata and mergedMetadata:is("table"), "Merged metadata not found")

		assert(mergedCollisions and mergedCollisions:is("table"), "Merged collisions not found")

		metadata = mergedMetadata

		collisions = mergedCollisions
	end

	local bundle = types.newtable()

	bundle:setreadproperty(parentsKey, sources)

	bundle:setreadproperty(genericsKey, genericCarrier)

	bundle:setreadproperty(bundleKey, bundleValue)

	bundle:setreadproperty(kindKey, kind)

	bundle:setreadproperty(specKey, spec)

	bundle:setreadproperty(metadataKey, metadata)

	bundle:setreadproperty(collisionsKey, collisions)

	bundle:setreadproperty(overrideKey, types.singleton(false))

	if kind == interfaceKind then
		return Pack(types.newtable(), bundle)
	end

	local views = BuildViews(metadata, kind, config, genericCarrier :: type)

	local selfView = views:readproperty(selfKey)

	local classView = views:readproperty(classKey)

	local implView = views:readproperty(implKey)

	assert(selfView and classView and implView, "Compiled views not found")

	bundle:setreadproperty(selfKey, selfView)

	bundle:setreadproperty(classKey, classView)

	bundle:setreadproperty(implKey, implView)

	if kind == traitKind then
		return Pack(selfView, bundle)
	end

	local objectView = views:readproperty(objectKey)

	assert(objectView, "Compiled object view not found")

	bundle:setreadproperty(objectKey, objectView)

	if HasProperties(collisions) == types.singleton(true) then
		return Pack(types.newtable(), bundle)
	end

	return Pack(objectView, bundle)
end

type function ApplyOverride(value: type, config: type): type
	local bundle = FindBundle(value, config)

	assert(bundle ~= types.never, "Override<T> requires a class bundle")

	assert(bundle:is("table"))

	local kindKey = ReadConf(config, "kindKey")

	local overrideKey = ReadConf(config, "overrideKey")

	local objectKey = ReadConf(config, "object")

	local classKind = ReadConf(config, "classKind")

	assert(bundle:readproperty(kindKey) == classKind, "Override<T> requires Class<...>")

	local resultBundle = types.newtable()

	for key, property in bundle:properties() do
		if property.read and property.write and property.read == property.write then
			resultBundle:setproperty(key, property.read)
		else
			if property.read then
				resultBundle:setreadproperty(key, property.read)
			end

			if property.write then
				resultBundle:setwriteproperty(key, property.write)
			end
		end
	end

	resultBundle:setreadproperty(overrideKey, types.singleton(true))

	local object = resultBundle:readproperty(objectKey)

	assert(object, "Override<T> class object not found")

	return Pack(object, resultBundle)
end

type function ConvertDispatch(value: type, target: type, config: type): type
	local bundle = FindBundle(value, config)

	if bundle == types.never then
		local classKind = ReadConf(config, "classKind")

		value = Compile(value, classKind, config, types.newfunction({ head = {} }, { head = {} }))

		bundle = FindBundle(value, config)
	end

	bundle = ValidateBundle(bundle, config)

	assert(bundle:is("table"))

	local primary = bundle:readproperty(target)

	assert(primary, "Return type not found in class bundle")

	return Pack(primary, bundle)
end

type function ObjectValues(value: type, config: type): type
	local bundle = ValidateBundle(value, config)

	assert(bundle:is("table"))

	local metadataKey = ReadConf(config, "metadataKey")

	local entryValueKey = ReadConf(config, "entryValueKey")

	local entryStaticKey = ReadConf(config, "entryStaticKey")

	local entryMethodKey = ReadConf(config, "entryMethodKey")

	assert(metadataKey and entryValueKey and entryStaticKey and entryMethodKey, "invalid config")

	local metadata = bundle:readproperty(metadataKey)

	assert(metadata and metadata:is("table"), "Class metadata not found")

	local result = types.newtable()

	for name, property in metadata:properties() do
		local entry = property.read or property.write

		assert(entry and entry:is("table"), "Invalid metadata entry")

		local memberValue = entry:readproperty(entryValueKey)

		local staticValue = entry:readproperty(entryStaticKey)

		local methodValue = entry:readproperty(entryMethodKey)

		assert(memberValue, "Metadata value not found")

		assert(staticValue and staticValue:is("singleton"))

		assert(methodValue and methodValue:is("singleton"))

		local isStatic = staticValue:value() == true

		local isMethod = methodValue:value() == true and memberValue:is("function")

		if not isStatic and not isMethod then
			result:setreadproperty(name, memberValue)
		end
	end

	return result
end

type function AssertObjectValues(class: type, value: type): type
	if not value:is("table") then
		error("Object value must be a table")
	end

	local required = ObjectValues(class, Config)

	if not value:issubtypeof(required) then
		error("Object value does not contain all required class fields")
	end

	return value
end

export type function ParentsOf(bundleValue: type, reference: type): type
	local bundle = FindBundle(bundleValue, Config)

	if bundle == types.never then
		error("ParentsOf<T, R> requires a class bundle")
	end

	assert(bundle:is("table"))

	local parentsKey = Config:readproperty(types.singleton("parentsKey"))

	local referenceKey = Config:readproperty(types.singleton("referenceKey"))

	assert(parentsKey and referenceKey, "invalid config")

	local target = reference:readproperty(referenceKey)

	if not target then
		error("ParentsOf<T, R> requires a valid class reference")
	end

	local parents = bundle:readproperty(parentsKey)

	assert(parents and parents:is("function"), "Class parent pack not found")

	local returns = parents:returns()

	if returns.tail then
		error("Class parent pack must be concrete")
	end

	local arguments: { type } = {}

	for _, parent in returns.head or {} do
		local parentBundle = FindBundle(parent, Config)

		if parentBundle == types.never then
			error("Invalid class parent")
		end

		assert(parentBundle:is("table"))

		local view = parentBundle:readproperty(target)

		if not view then
			error("Parent does not provide requested reference view")
		end

		table.insert(arguments, Pack(view, parentBundle))
	end

	return types.newfunction({

		head = arguments,
	}, {

		head = {},
	})
end

-- References

type SelfReference<A...> = Reference<index<Config, "self">, () -> A..., Config>
type ObjectReference<A...> = Reference<index<Config, "object">, () -> A..., Config>
type ClassReference<A...> = Reference<index<Config, "class">, () -> A..., Config>
type ImplReference<A...> = Reference<index<Config, "impl">, () -> A..., Config>

export type Generic<A... = ()> = () -> A...

export type Self<A... = ()> = SelfReference<A...>
export type Object<A... = ()> = ObjectReference<A...>
export type ClassType<A... = ()> = ClassReference<A...>
export type Impl<A... = ()> = ImplReference<A...>

-- Views

export type View<T, K> = ConvertDispatch<T, K, Config>

export type ViewOf<T, K> = Extract<T, K, Config>

--[[

    this returns a bundle with object view as primary, so user can use the type

    Type = Class<{}> to point to object of the class

]]

export type Class<T, A...> = Compile<T, index<Config, "classKind">, Config, () -> A...>

export type Interface<T> = Compile<T, index<Config, "interfaceKind">, Config, () -> ()>

export type Trait<T> = Compile<T, index<Config, "traitKind">, Config, () -> ()>

export type Override<T> = ApplyOverride<T, Config>

export type ToClass<T> = ConvertDispatch<T, index<Config, "class">, Config>

export type ToObject<T> = ConvertDispatch<T, index<Config, "object">, Config>

export type ToSelf<T> = ConvertDispatch<T, index<Config, "self">, Config>

export type ToImpl<T> = ConvertDispatch<T, index<Config, "impl">, Config>

export type ToSpec<T> = ConvertDispatch<T, index<Config, "spec">, Config>

-- Extractors

export type ClassOf<T> = Extract<T, index<Config, "class">, Config>

export type ObjectOf<T> = Extract<T, index<Config, "object">, Config>

export type SelfOf<T> = Extract<T, index<Config, "self">, Config>

export type ImplOf<T> = Extract<T, index<Config, "impl">, Config>

export type SpecOf<T> = Extract<T, index<Config, "spec">, Config>

-- Modifiers

export type Public<T> = Modifier<index<Config, "public">, T, Config>

export type Protected<T> = Modifier<index<Config, "protected">, T, Config>

export type Private<T> = Modifier<index<Config, "private">, T, Config>

export type Static<T> = Modifier<index<Config, "static">, T, Config>

export type Method<T> = Modifier<index<Config, "method">, T, Config>

export type Field<T> = Modifier<index<Config, "field">, T, Config>

export type Const<T> = Modifier<index<Config, "const">, T, Config>

export type Var<T> = Modifier<index<Config, "var">, T, Config>

export type Mut<T> = Modifier<index<Config, "mut">, T, Config>

export type Immut<T> = Modifier<index<Config, "immut">, T, Config>

export type Constructor<T> = Modifier<index<Config, "constructor">, T, Config>

export type ObjectValuesOf<T> = ObjectValues<T, Config>

export type AssertObjectValuesOf<T, V> = AssertObjectValues<T, V>

return nil
