--!strict

--[[

	OOP-FRAMEWORK

	FULL TYPE-SIDE LOGIC + API

	----------------------
	NAME GUIDE:

	SPEC -> USER DEFINED TYPE THAT DESCRIBES MEMBERS OF A CLASS / INTERFACE / TRAIT

	OBJECT -> PUBLIC RUNTIME INSTANCE TYPE OF THE CLASS (RETURN TYPE OF CONSTRUCTOR)

	SELF -> INTERNAL INSTANCE TYPE USED BY METHODS AND CLASS IMPLEMENTATION

	IMPL -> IMPLEMENTATION TABLE TYPE WHERE USER DECLARES METHODS / STATIC MEMBERS

	CLASS -> PUBLIC STATIC SIDE OF THE CLASS

	BUNDLE -> HIDDEN COMPILED CLASS DATA PACKED WITH A PRIMARY VIEW USING
	A & (A | B) = A
	WHERE A IS THE SELECTED PRIMARY TYPE AND B IS THE HIDDEN BUNDLE

	METADATA -> COMPILED MEMBER INFORMATION USED TO BUILD VIEWS AND SUPPORT INHERITANCE

	LOCAL METADATA -> METADATA GENERATED ONLY FROM THE CURRENT CLASS SPEC BEFORE PARENT MERGING

	EXTRACTOR -> RETURNS A PURE VIEW FROM A BUNDLE
	(EX: ObjectOf<>, SelfOf<>, ClassOf<>, ImplOf<>, SpecOf<>)

	VIEW -> RETURNS THE SAME BUNDLE WITH A DIFFERENT PRIMARY TYPE
	(EX: ToObject<>, ToSelf<>, ToClass<>, ToImpl<>, ToSpec<>)

	REFERENCE -> PLACEHOLDER TYPE USED INSIDE SPECS TO REFER TO SELF / OBJECT / CLASS / IMPL
	THE COMPILER RESOLVES THESE REFERENCES WHILE BUILDING FINAL VIEWS

	MODIFIER -> TYPE WRAPPER THAT CHANGES HOW A SPEC MEMBER IS COMPILED

	PUBLIC -> MEMBER IS EXPOSED THROUGH PUBLIC VIEWS

	PROTECTED -> MEMBER IS AVAILABLE TO INTERNAL / INHERITED CLASS VIEWS BUT NOT PUBLIC OBJECT

	PRIVATE -> MEMBER REMAINS LOCAL TO THE CLASS AND IS NOT INHERITED

	STATIC -> MEMBER BELONGS TO CLASS / IMPL INSTEAD OF OBJECT / SELF

	METHOD -> FUNCTION RECEIVES SELF AS ITS FIRST ARGUMENT

	FIELD -> VALUE IS TREATED AS A NORMAL FIELD EVEN IF IT IS A FUNCTION

	CONST -> MEMBER IS READONLY IN USER FACING VIEWS

	VAR -> MEMBER IS WRITABLE

	MUT -> TABLE VALUE REMAINS MUTABLE

	IMMUT -> TABLE VALUE IS RECURSIVELY CONVERTED INTO A READONLY TYPE

	CONSTRUCTOR -> FUNCTION IS FORCED STATIC AND ITS RETURN TYPE IS REPLACED WITH OBJECT

	SUPERCLASS -> CLASS INHERITED BY ANOTHER CLASS
	ONLY ONE SUPERCLASS MAY EXIST IN A CLASS COMPOSITION

	INTERFACE -> TYPE ONLY PARENT THAT CONTRIBUTES REQUIRED MEMBER METADATA

	TRAIT -> COMPOSABLE PARENT THAT CONTRIBUTES MEMBERS AND CAN LATER HAVE RUNTIME IMPLEMENTATION

	PARENTS -> SUPERCLASS + TRAITS + INTERFACES PASSED INTO Class<T, A...>

	CHILD -> CLASS THAT INHERITS / COMPOSES PARENTS

	COLLISION -> TWO OR MORE PARENTS PROVIDE THE SAME INHERITED MEMBER

	OVERRIDE -> MARKS A COMPOSED CLASS AS INTENTIONALLY RESOLVING ITS PARENT COLLISIONS

	FAMILY -> ORIGINAL CLASS BUNDLE SHARED BY ALL REFINED VERSIONS OF THAT CLASS

	REFINE -> CREATES A NEW VERSION OF AN EXISTING CLASS FAMILY BY NARROWING EXISTING MEMBERS
	AND OPTIONALLY REPLACING PARENT FAMILIES

	BASE -> ORIGINAL UNREFINED CLASS FAMILY USED BY Refine<>

	BASEOF -> RETURNS THE BASE CLASS VIEW OF A CLASS FAMILY

	TOBASE -> RETURNS THE BASE CLASS BUNDLE WITH CLASS AS ITS PRIMARY VIEW

	PARENTSOF -> RETURNS A FUNCTION TYPE WHOSE ARGUMENTS ARE THE SELECTED VIEWS OF ALL PARENTS

	OBJECTVALUESOF -> EXTRACTS ONLY NON-STATIC NON-METHOD OBJECT FIELD VALUES

	ASSERTOBJECTVALUESOF -> VALIDATES THAT A TABLE CONTAINS EXACTLY THE REQUIRED OBJECT FIELD VALUES

	----------------------

	----------------------
	COMPILATION PIPELINE:

	CLASS / INTERFACE / TRAIT SPEC
		+
	PARENT PACK
	->

	UNWRAP MEMBER MODIFIERS
	->

	COMPILE LOCAL METADATA
		VALUE
		VISIBILITY
		STATIC STATE
		METHOD STATE
		CONST STATE
	->

	IF CLASS:
		VALIDATE PARENT BUNDLES
		VALIDATE SINGLE SUPERCLASS
		VALIDATE UNRESOLVED PARENT COLLISIONS
	->

	MERGE INHERITABLE PARENT METADATA
		PRIVATE MEMBERS ARE SKIPPED
		LOCAL SPEC HAS FINAL PRIORITY
	->

	DETECT + STORE PARENT COLLISIONS
	->

	BUILD BUNDLE METADATA
		SPEC
		PARENTS
		FAMILY
		KIND
		LOCAL METADATA
		MERGED METADATA
		COLLISIONS
		OVERRIDE STATE
	->

	IF INTERFACE:
		PACK EMPTY PRIMARY VIEW + BUNDLE
		RETURN
	->

	BUILD SELF / OBJECT / CLASS / IMPL VIEWS
	->

	INJECT SELF INTO METHOD FUNCTIONS
	->

	RESOLVE SELF / OBJECT / CLASS / IMPL REFERENCES
	->

	APPLY VIEW VISIBILITY + CONST / VAR RULES
	->

	ATTACH COMPILED VIEWS TO BUNDLE
	->

	IF TRAIT:
		PACK SELF VIEW + BUNDLE
		RETURN
	->

	IF CLASS HAS UNRESOLVED COLLISIONS:
		PACK EMPTY PRIMARY VIEW + BUNDLE
	ELSE
		PACK OBJECT VIEW + BUNDLE
	->

	RETURN FINAL COMPILED BUNDLE

	----------------------

	----------------------
	REFINEMENT PIPELINE:

	REFINE BASE CLASS
		+
	REFINEMENT SPEC
		+
	OPTIONAL REPLACEMENT PARENTS
	->

	FIND BASE BUNDLE + CLASS FAMILY
	->

	VALIDATE NEW PARENT FAMILIES
	->

	REPLACE MATCHING PARENT FAMILIES
	->

	COMPILE REFINEMENT SPEC INTO METADATA
	->

	VALIDATE THAT REFINED MEMBERS ALREADY EXIST
	->

	VALIDATE FIELD / FUNCTION COMPATIBILITY
	->

	VALIDATE FUNCTION ARITY + GENERICS
	->

	NARROW MEMBER VALUES
	->

	MARK REFINED ENTRIES
	->

	RECOMPILE USING ORIGINAL FAMILY + BASE OBJECT
	->

	BUILD REFINED VIEWS WHILE PRESERVING BASE OBJECT REFERENCE SEMANTICS
	->

	RETURN REFINED CLASS BUNDLE

	----------------------

]]

type Config = {
	modifierKey: "__class_modifier",
	valueKey: "__class_value",
	referenceKey: "__class_reference",
	bundleKey: "__class_bundle",
	bundleValue: "__class_bundle_v1",
	parentsKey: "__class_parents",
	familyKey: "__class_family",

	metadataKey: "__class_metadata",
	localMetadataKey: "__class_local_metadata",
	kindKey: "__class_kind",
	collisionsKey: "__class_collisions",
	overrideKey: "__class_override",

	entryValueKey: "__class_entry_value",
	entryVisibilityKey: "__class_entry_visibility",
	entryStaticKey: "__class_entry_static",
	entryMethodKey: "__class_entry_method",
	entryConstKey: "__class_entry_const",
	entryRefinedKey: "__class_entry_refined",

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

type function CompilerError(message: string): type
	error("OOP compiler error\n  " .. message)
end

type function ReadConf(config: type, name: string): type
	local value = config:readproperty(types.singleton(name))
	assert(value, "OOP compiler error\n  Invalid configuration: missing " .. name)
	return value
end

type function Reference(target: type, config: type): type
	local referenceKey = ReadConf(config, "referenceKey")

	local result = types.newtable()
	result:setproperty(referenceKey, target)

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

type function CollisionNames(collisions: type): string
	local names: { string } = {}

	for name in collisions:properties() do
		if name:is("singleton") then
			table.insert(names, tostring(name:value()))
		end
	end

	table.sort(names)
	return table.concat(names, ", ")
end

type function ValidateBundle(value: type, config: type): type
	local bundle = FindBundle(value, config)

	assert(bundle ~= types.never and bundle:is("table"), "OOP compiler error\n  Expected a compiled class bundle.")
	
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
		local names = CollisionNames(collisions)
		if names ~= "" then
			CompilerError(
				"Class inheritance collision: "
					.. names
					.. "\n  Use Override<...> to resolve collisions by composition order."
			)
		end
	end

	return bundle
end

type function Extract(value: type, target: type, config: type): type
	local bundle = ValidateBundle(value, config)
	assert(bundle:is("table"), "OOP compiler error\n  Invalid class bundle in extractor.")

	local result = bundle:readproperty(target)
	assert(result, "OOP compiler error\n  Requested view is not available in this class bundle.")

	return result
end

type function MakeImmutable(value: type, config: type): type
	if not value:is("table") then
		CompilerError("Immut<T> requires a table type.")
	end

	local referenceKey = ReadConf(config, "referenceKey")

	local cache: { [type]: type } = {}
	local active: { [type]: boolean } = {}

	local function freeze(source: type): type
		local cached = cache[source]

		if cached then
			return cached
		end
		if active[source] then
			CompilerError("Immut<T> cannot resolve a recursive table whose cycle passes through an indexer.")
		end

		local tag = source.tag

		if tag == "table" then
			if source:readproperty(referenceKey) then
				return source
			end

			local sourceIndexer = source:indexer()
			local indexer = nil
			if sourceIndexer then
				active[source] = true
				indexer = {
					index = freeze(sourceIndexer.index),
					readresult = freeze(sourceIndexer.readresult),
					writeresult = types.never,
				}
			end

			local result = types.newtable(nil, indexer)
			cache[source] = result
			active[source] = nil

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
		CompilerError("Class, Interface, and Trait specifications must be table types.")
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

	local objectKey = ReadConf(config, "object")
	local classKind = ReadConf(config, "classKind")

	local metadata = types.newtable()
	local kindName = tostring(kind:value())

	local function compileMember(name: type, propertyType: type): type
		local memberName = tostring(name:value())
		local chain: { type } = {}
		local value = propertyType

		while value:is("table") do
			local modifier = value:readproperty(modifierKey)

			if not modifier then
				break
			end

			assert(
				modifier:is("singleton"),
				"OOP compiler error\n  Member '" .. memberName .. "': modifier must be a singleton."
			)

			local inner = value:readproperty(valueKey)
			assert(inner, "OOP compiler error\n  Member '" .. memberName .. "': modifier wrapper has no value.")

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
					CompilerError("Member '" .. memberName .. "': " .. kindName .. " cannot declare Constructor<T>.")
				end

				if not currentValue:is("function") then
					CompilerError("Member '" .. memberName .. "': Constructor<T> requires a function type.")
				end

				currentValue = types.newfunction(currentValue:parameters(), {
					head = { Reference(objectKey, config) },
				}, currentValue:generics())

				isStatic = true
				isMethod = false
			else
				CompilerError("Member '" .. memberName .. "': unknown class modifier " .. tostring(modifier) .. ".")
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
		local propertyType = property.read or property.write
		assert(propertyType, "OOP compiler error\n  Member '" .. tostring(name) .. "' has no type.")

		metadata:setreadproperty(name, compileMember(name, propertyType))
	end

	return metadata
end

type function MergeMetadata(localMetadata: type, config: type, sources: type)
	assert(localMetadata:is("table"), "OOP compiler error\n  Local metadata must be a table.")

	local kindKey = ReadConf(config, "kindKey")
	local metadataKey = ReadConf(config, "metadataKey")
	local collisionsKey = ReadConf(config, "collisionsKey")
	local overrideKey = ReadConf(config, "overrideKey")

	local entryVisibilityKey = ReadConf(config, "entryVisibilityKey")

	local privateKey = ReadConf(config, "private")
	local classKind = ReadConf(config, "classKind")
	local interfaceKind = ReadConf(config, "interfaceKind")
	local traitKind = ReadConf(config, "traitKind")

	assert(sources:is("function"), "OOP compiler error\n  Class composition source pack must be a function type.")

	local sourceReturns = sources:returns()

	if sourceReturns.tail then
		CompilerError("Class composition source pack must be concrete.")
	end

	local sourceList = sourceReturns.head or {}

	local merged = types.newtable()
	local collisions = types.newtable()
	local seen: { [string]: boolean } = {}
	local superCount = 0

	local function validateSource(bundle: type)
		local sourceKind = bundle:readproperty(kindKey)
		assert(sourceKind, "OOP compiler error\n  Composition source kind not found.")

		if sourceKind ~= classKind and sourceKind ~= interfaceKind and sourceKind ~= traitKind then
			CompilerError("Composition source must be a class, interface, or trait.")
		end

		if sourceKind == classKind then
			superCount += 1

			if superCount > 1 then
				CompilerError("Class<T, A...> accepts at most one superclass.")
			end
		end

		local sourceCollisions = bundle:readproperty(collisionsKey)
		local sourceOverridden = bundle:readproperty(overrideKey) == types.singleton(true)

		if sourceCollisions and sourceCollisions:is("table") and not sourceOverridden then
			local names = CollisionNames(sourceCollisions)
			if names ~= "" then
				CompilerError(
					"Composition source contains unresolved inheritance collisions: "
						.. names
						.. "\n  Resolve collisions with Override<...> before composing this source."
				)
			end
		end
	end

	for sourceIndex = 1, #sourceList do
		local source = sourceList[sourceIndex]
		local bundle = FindBundle(source, config)

		if bundle == types.never then
			CompilerError("Class composition arguments must be Class<...>, Interface<...>, or Trait<...> bundles.")
		end

		assert(bundle:is("table"), "OOP compiler error\n  Invalid composition source bundle.")
		validateSource(bundle)

		local sourceMetadata = bundle:readproperty(metadataKey)
		assert(
			sourceMetadata and sourceMetadata:is("table"),
			"OOP compiler error\n  Composition source metadata not found."
		)

		for name, property in sourceMetadata:properties() do
			local entry = property.read or property.write
			assert(
				entry and entry:is("table"),
				"OOP compiler error\n  Invalid composition metadata entry for '" .. tostring(name) .. "'."
			)

			local visibility = entry:readproperty(entryVisibilityKey)

			assert(
				visibility and visibility:is("singleton"),
				"OOP compiler error\n  Invalid composition visibility for '" .. tostring(name) .. "'."
			)

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
		assert(entry, "OOP compiler error\n  Invalid local metadata entry for '" .. tostring(name) .. "'.")

		merged:setreadproperty(name, entry)
	end

	local result = types.newtable()
	result:setreadproperty(metadataKey, merged)
	result:setreadproperty(collisionsKey, collisions)

	return result
end

type function BuildViews(metadata: type, kind: type, config: type, baseObject: type?)
	assert(metadata:is("table"), "OOP compiler error\n  View metadata must be a table.")

	local referenceKey = ReadConf(config, "referenceKey")

	local entryValueKey = ReadConf(config, "entryValueKey")
	local entryVisibilityKey = ReadConf(config, "entryVisibilityKey")
	local entryStaticKey = ReadConf(config, "entryStaticKey")
	local entryMethodKey = ReadConf(config, "entryMethodKey")
	local entryConstKey = ReadConf(config, "entryConstKey")
	local entryRefinedKey = ReadConf(config, "entryRefinedKey")

	local publicKey = ReadConf(config, "public")

	local selfKey = ReadConf(config, "self")
	local objectKey = ReadConf(config, "object")
	local classKey = ReadConf(config, "class")
	local implKey = ReadConf(config, "impl")

	local classKind = ReadConf(config, "classKind")
	local traitKind = ReadConf(config, "traitKind")

	if kind ~= classKind and kind ~= traitKind then
		CompilerError("Only classes and traits have compiled views.")
	end

	local compiledSelf = types.newtable()
	local compiledObject = if kind == classKind then types.newtable() else nil
	local compiledClass = types.newtable()
	local compiledImpl = types.newtable()

	local selfReference = Reference(selfKey, config)
	local objectReference = Reference(objectKey, config)
	local classReference = Reference(classKey, config)

	local function referenceTarget(referenceValue: type): type?
		if referenceValue == selfKey then
			return compiledSelf
		elseif referenceValue == objectKey then
			if not compiledObject then
				CompilerError("Object references are not available in Trait<...>.")
			end

			return compiledObject
		elseif referenceValue == classKey then
			return compiledClass
		elseif referenceValue == implKey then
			return compiledImpl
		end

		return nil
	end

	local baseCache: { [type]: type } = {}
	local refinedCache: { [type]: type } = {}
	local baseActive: { [type]: boolean } = {}
	local refinedActive: { [type]: boolean } = {}
	local function resolveMember(value: type, refined: boolean): type
		local resolveCache = if refined then refinedCache else baseCache
		local resolveActive = if refined then refinedActive else baseActive
		local function resolve(source: type): type
			if baseObject and source == baseObject then
				return baseObject
			end
			local cached = resolveCache[source]

			if cached then
				return cached
			end

			local tag = source.tag

			if tag == "table" then
				local referenceValue = source:readproperty(referenceKey)

				if referenceValue then
					local target = referenceTarget(referenceValue)

					if target then
						if baseObject and not refined and referenceValue == objectKey then
							target = baseObject
						end
						resolveCache[source] = target
						return target
					end
				end

				local sourceIndexer = source:indexer()

				if not sourceIndexer then
					local result = types.newtable()
					resolveCache[source] = result

					for key, property in source:properties() do
						if property.read and property.write and property.read == property.write then
							result:setproperty(key, resolve(property.read))
						else
							if property.read then
								result:setreadproperty(key, resolve(property.read))
							end

							if property.write then
								result:setwriteproperty(key, resolve(property.write))
							end
						end
					end

					local metatable = source:metatable()

					if metatable then
						result:setmetatable(resolve(metatable))
					end

					return result
				end

				if resolveActive[source] then
					CompilerError(
						"Class resolver cannot resolve a recursive table whose cycle passes through an indexer."
					)
				end
				resolveActive[source] = true
				local properties: { [type]: type } | { [type]: { read: type?, write: type? } } = {}
				for key, property in source:properties() do
					if property.read and property.write and property.read == property.write then
						properties[key] = resolve(property.read)
					else
						properties[key] = {
							read = property.read and resolve(property.read) or nil,
							write = property.write and resolve(property.write) or nil,
						}
					end
				end

				local metatable = source:metatable()
				local result = types.newtable(properties, {
					index = resolve(sourceIndexer.index),
					readresult = resolve(sourceIndexer.readresult),
					writeresult = resolve(sourceIndexer.writeresult),
				}, metatable and resolve(metatable) or nil)
				resolveCache[source] = result
				resolveActive[source] = nil

				return result
			end

			if tag == "function" then
				local result = types.newfunction({
					head = {},
				}, {
					head = {},
				}, source:generics())

				resolveCache[source] = result

				local parameters = source:parameters()
				local returns = source:returns()
				local parameterHead: { type } = {}
				local returnHead: { type } = {}

				if parameters.head then
					for _, parameter in parameters.head do
						table.insert(parameterHead, resolve(parameter))
					end
				end

				if returns.head then
					for _, returnType in returns.head do
						table.insert(returnHead, resolve(returnType))
					end
				end

				result:setparameters(parameterHead, parameters.tail and resolve(parameters.tail) or nil)
				result:setreturns(returnHead, returns.tail and resolve(returns.tail) or nil)

				return result
			end

			if tag == "union" or tag == "intersection" then
				local components: { type } = {}

				for _, component in source:components() do
					table.insert(components, resolve(component))
				end

				local result: type

				if tag == "union" then
					result = types.unionof(unpack(components))
				else
					result = types.intersectionof(unpack(components))
				end

				resolveCache[source] = result

				return result
			end

			if tag == "negation" then
				local result = types.negationof(resolve(source:inner()))
				resolveCache[source] = result

				return result
			end

			resolveCache[source] = source

			return source
		end
		return resolve(value)
	end

	local function injectFirst(func: type, argument: type)
		assert(func:is("function"), "OOP compiler error\n  Method injection requires a function type.")

		local parameters = func:parameters()
		local head: { type } = { argument }

		if parameters.head then
			for _, parameter in parameters.head do
				table.insert(head, parameter)
			end
		end

		return types.newfunction({
			head = head,
			tail = parameters.tail,
		}, func:returns(), func:generics())
	end

	local function emit(
		target: type,
		reference: type,
		name: type,
		value: type,
		isMethod: boolean,
		isConst: boolean,
		refined: boolean
	)
		if isMethod and value:is("function") then
			value = injectFirst(value, reference)
		end

		value = resolveMember(value, refined)

		if isConst then
			target:setreadproperty(name, value)
		else
			target:setproperty(name, value)
		end
	end

	for name, property in metadata:properties() do
		local entry = property.read or property.write
		assert(
			entry and entry:is("table"),
			"OOP compiler error\n  Invalid metadata entry for '" .. tostring(name) .. "'."
		)

		local value = entry:readproperty(entryValueKey)
		local visibility = entry:readproperty(entryVisibilityKey)
		local staticValue = entry:readproperty(entryStaticKey)
		local methodValue = entry:readproperty(entryMethodKey)
		local constValue = entry:readproperty(entryConstKey)
		local refinedValue = entry:readproperty(entryRefinedKey)

		assert(value, "OOP compiler error\n  Member '" .. tostring(name) .. "': metadata value not found.")
		assert(
			visibility and visibility:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata visibility not found."
		)
		assert(
			staticValue and staticValue:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata static state not found."
		)
		assert(
			methodValue and methodValue:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata method state not found."
		)
		assert(
			constValue and constValue:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata const state not found."
		)

		local isPublic = visibility == publicKey
		local isStatic = staticValue:value() == true
		local isMethod = methodValue:value() == true
		local isConst = constValue:value() == true
		local isFunction = value:is("function")
		local isRefined = refinedValue == types.singleton(true)

		if isStatic then
			if isPublic then
				emit(compiledClass, classReference, name, value, isMethod, isConst, isRefined)
			end

			emit(compiledImpl, selfReference, name, value, isMethod, false, isRefined)
		else
			emit(compiledSelf, selfReference, name, value, isMethod, isConst, isRefined)

			if isPublic and compiledObject then
				emit(compiledObject, objectReference, name, value, isMethod, isConst, isRefined)
			end

			if isFunction then
				emit(compiledImpl, selfReference, name, value, isMethod, false, isRefined)
			end
		end
	end

	local result = types.newtable()
	result:setreadproperty(selfKey, compiledSelf)
	result:setreadproperty(classKey, compiledClass)
	result:setreadproperty(implKey, compiledImpl)

	if compiledObject then
		result:setreadproperty(objectKey, compiledObject)
	end

	return result
end

type function CompileWithMetadata(
	spec: type,
	kind: type,
	config: type,
	sources: type,
	localMetadata: type,
	family: type?,
	baseObject: type?
): type
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

	local classKind = ReadConf(config, "classKind")
	local interfaceKind = ReadConf(config, "interfaceKind")
	local traitKind = ReadConf(config, "traitKind")

	if kind ~= classKind and kind ~= interfaceKind and kind ~= traitKind then
		CompilerError("Bundle kind must be class, interface, or trait.")
	end

	assert(sources:is("function"), "OOP compiler error\n  Composition source pack must be a function type.")

	local sourceReturns = sources:returns()

	if sourceReturns.tail then
		CompilerError("Composition source pack must be concrete.")
	end

	if kind ~= classKind and sourceReturns.head and #sourceReturns.head > 0 then
		CompilerError("Only Class<T, A...> accepts composition arguments.")
	end

	local metadata = localMetadata
	local collisions = types.newtable()

	if kind == classKind then
		local merged = MergeMetadata(localMetadata, config, sources)
		local mergedMetadata = merged:readproperty(metadataKey)
		local mergedCollisions = merged:readproperty(collisionsKey)

		assert(mergedMetadata and mergedMetadata:is("table"), "OOP compiler error\n  Merged metadata not found.")
		assert(mergedCollisions and mergedCollisions:is("table"), "OOP compiler error\n  Merged collisions not found.")

		metadata = mergedMetadata
		collisions = mergedCollisions
	end

	local bundle = types.newtable()
	bundle:setreadproperty(parentsKey, sources)
	bundle:setreadproperty(ReadConf(config, "familyKey"), family or bundle)
	bundle:setreadproperty(bundleKey, bundleValue)
	bundle:setreadproperty(kindKey, kind)
	bundle:setreadproperty(specKey, spec)
	bundle:setreadproperty(metadataKey, metadata)
	bundle:setreadproperty(ReadConf(config, "localMetadataKey"), localMetadata)
	bundle:setreadproperty(collisionsKey, collisions)
	bundle:setreadproperty(overrideKey, types.singleton(false))

	if kind == interfaceKind then
		return Pack(types.newtable(), bundle)
	end

	local views = BuildViews(metadata, kind, config, baseObject)
	local selfView = views:readproperty(selfKey)
	local classView = views:readproperty(classKey)
	local implView = views:readproperty(implKey)

	assert(
		selfView and classView and implView,
		"OOP compiler error\n  Compiled self, class, or implementation view not found."
	)

	bundle:setreadproperty(selfKey, selfView)
	bundle:setreadproperty(classKey, classView)
	bundle:setreadproperty(implKey, implView)

	if kind == traitKind then
		return Pack(selfView, bundle)
	end

	local objectView = views:readproperty(objectKey)
	assert(objectView, "OOP compiler error\n  Compiled object view not found.")

	bundle:setreadproperty(objectKey, objectView)

	if HasProperties(collisions) == types.singleton(true) then
		return Pack(types.newtable(), bundle)
	end

	return Pack(objectView, bundle)
end

type function Compile(spec: type, kind: type, config: type, sources: type): type
	return CompileWithMetadata(spec, kind, config, sources, CompileMetadata(spec, kind, config), nil, nil)
end

type function RefineClass(base: type, spec: type, config: type, extraParents: type): type
	local bundle = FindBundle(base, config)
	assert(bundle ~= types.never and bundle:is("table"), "OOP compiler error\n  Refine requires a compiled class.")
	assert(
		bundle:readproperty(ReadConf(config, "kindKey")) == ReadConf(config, "classKind"),
		"OOP compiler error\n  Refine requires Class<...>."
	)
	assert(spec:is("table"), "OOP compiler error\n  Refine overrides must be a table.")

	local parentsKey = ReadConf(config, "parentsKey")
	local familyKey = ReadConf(config, "familyKey")
	local metadataKey = ReadConf(config, "metadataKey")
	local localMetadataKey = ReadConf(config, "localMetadataKey")
	local entryValueKey = ReadConf(config, "entryValueKey")
	local entryRefinedKey = ReadConf(config, "entryRefinedKey")
	local oldParents = bundle:readproperty(parentsKey)
	assert(oldParents and oldParents:is("function"), "OOP compiler error\n  Refine base parent pack not found.")
	local oldReturns = oldParents:returns()
	local newReturns = extraParents:returns()
	assert(not oldReturns.tail and not newReturns.tail, "OOP compiler error\n  Refine parents must be concrete.")
	local sources: { type } = {}
	local added: { type } = {}
	for _, parent in newReturns.head or {} do
		local parentBundle = FindBundle(parent, config)
		assert(
			parentBundle ~= types.never and parentBundle:is("table"),
			"OOP compiler error\n  Refine parent must be a class, trait, or interface."
		)
		local family = parentBundle:readproperty(familyKey)
		assert(family, "OOP compiler error\n  Refine parent family missing.")
		for _, existing in added do
			if existing == family then
				CompilerError("Refine cannot add the same parent family twice.")
			end
		end
		table.insert(added, family)
	end
	for _, parent in oldReturns.head or {} do
		local parentBundle = FindBundle(parent, config)
		assert(
			parentBundle ~= types.never and parentBundle:is("table"),
			"OOP compiler error\n  Refine base contains an invalid parent bundle."
		)
		local family = parentBundle:readproperty(familyKey)
		local replaced = false
		for _, incoming in added do
			if incoming == family then
				replaced = true
				break
			end
		end
		if not replaced then
			table.insert(sources, parent)
		end
	end
	for _, parent in newReturns.head or {} do
		table.insert(sources, parent)
	end

	local original = bundle:readproperty(metadataKey)
	local localMetadata = bundle:readproperty(localMetadataKey)
	local family = bundle:readproperty(familyKey)
	assert(family and family:is("table"), "OOP compiler error\n  Refine class family missing.")
	local baseObject = family:readproperty(ReadConf(config, "object"))
	assert(
		original and original:is("table") and localMetadata and localMetadata:is("table") and baseObject,
		"OOP compiler error\n  Refine base metadata or object view is missing."
	)
	local refined = types.copy(localMetadata)
	local replacements = CompileMetadata(spec, ReadConf(config, "classKind"), config)
	for name, property in replacements:properties() do
		local replacement = property.read or property.write
		local existing = original:readproperty(name)
		assert(
			replacement and existing,
			"OOP compiler error\n  Refine cannot introduce member '" .. tostring(name) .. "'."
		)
		local oldValue = existing:readproperty(entryValueKey)
		local newValue = replacement:readproperty(entryValueKey)
		assert(oldValue and newValue, "OOP compiler error\n  Refine member '" .. tostring(name) .. "' has no value.")

		-- Refinements may narrow constructor arguments, so function subtyping alone is too strict.
		if oldValue:is("function") ~= newValue:is("function") then
			CompilerError("Refine member '" .. tostring(name) .. "' cannot change between function and field.")
		end

		if oldValue.tag ~= "function" and not newValue:issubtypeof(oldValue) then
			CompilerError("Refine member '" .. tostring(name) .. "' must be a subtype of the base member.")
		end

		if oldValue:is("function") and newValue:is("function") then
			local oldParams = oldValue:parameters()
			local newParams = newValue:parameters()
			local oldResults = oldValue:returns()
			local newResults = newValue:returns()
			local oldGenerics = oldValue:generics() or {}
			local newGenerics = newValue:generics() or {}
			local objectReference = Reference(ReadConf(config, "object"), config)

			if #oldGenerics ~= #newGenerics then
				CompilerError(
					"Refine member '" .. tostring(name) .. "': function must preserve its generic parameters."
				)
			end
			if #oldGenerics > 0 and newValue ~= oldValue then
				CompilerError("Refine member '" .. tostring(name) .. "': cannot change a generic function signature.")
			end

			local function comparePack(
				old: { head: { type }?, tail: type? },
				new: { head: { type }?, tail: type? },
				label: string
			)
				local oldHead = old.head or {}
				local newHead = new.head or {}
				if #oldHead ~= #newHead or (old.tail == nil) ~= (new.tail == nil) then
					CompilerError(
						"Refine member '" .. tostring(name) .. "': function must preserve " .. label .. " arity."
					)
				end
				for i, oldType in oldHead do
					local newType = newHead[i]
					local compatible = newType == oldType
					if not compatible and label == "returns" and oldType == objectReference then
						compatible = newType == baseObject or newType:issubtypeof(baseObject)
					end
					if not compatible and not newType:issubtypeof(oldType) then
						CompilerError(
							"Refine member '"
								.. tostring(name)
								.. "': function "
								.. label
								.. " must narrow the base type."
						)
					end
				end
				if old.tail and new.tail and new.tail ~= old.tail and not new.tail:issubtypeof(old.tail) then
					CompilerError(
						"Refine member '"
							.. tostring(name)
							.. "': function "
							.. label
							.. " tail must narrow the base type."
					)
				end
			end

			comparePack(oldParams, newParams, "parameters")
			comparePack(oldResults, newResults, "returns")
		end

		local entry = types.copy(existing)
		entry:setreadproperty(entryValueKey, newValue)
		entry:setreadproperty(entryRefinedKey, types.singleton(true))
		refined:setreadproperty(name, entry)
	end
	local parents = types.newfunction({ head = {} }, { head = sources })
	return CompileWithMetadata(
		bundle:readproperty(ReadConf(config, "spec")) :: type,
		ReadConf(config, "classKind"),
		config,
		parents,
		refined,
		family,
		baseObject
	)
end

type function ApplyOverride(value: type, config: type): type
	local bundle = FindBundle(value, config)

	assert(bundle ~= types.never and bundle:is("table"), "OOP compiler error\n  Override<T> requires a class bundle.")

	local kindKey = ReadConf(config, "kindKey")
	local overrideKey = ReadConf(config, "overrideKey")
	local objectKey = ReadConf(config, "object")
	local classKind = ReadConf(config, "classKind")

	assert(bundle:readproperty(kindKey) == classKind, "OOP compiler error\n  Override<T> requires Class<...>.")

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
	assert(object, "OOP compiler error\n  Override<T> class object view not found.")

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
	assert(bundle:is("table"), "OOP compiler error\n  Invalid class bundle in view conversion.")

	local primary = bundle:readproperty(target)
	assert(primary, "OOP compiler error\n  Requested view is not available in this class bundle.")

	return Pack(primary, bundle)
end

type function BaseBundle(value: type): type
	local bundle = FindBundle(value, Config)
	assert(bundle ~= types.never and bundle:is("table"), "OOP compiler error\n  BaseOf<T> requires a class bundle.")
	local family = bundle:readproperty(ReadConf(Config, "familyKey"))
	assert(family and family:is("table"), "OOP compiler error\n  Class base family not found.")
	return family
end

type function BaseView(value: type, target: type): type
	local base = BaseBundle(value)
	local view = base:readproperty(target)
	assert(view, "OOP compiler error\n  Requested class base view not found.")
	return Pack(view, base)
end

type function ObjectValues(value: type, config: type): type
	local bundle = ValidateBundle(value, config)
	assert(bundle:is("table"), "OOP compiler error\n  Invalid class bundle for ObjectValuesOf<T>.")

	local metadataKey = ReadConf(config, "metadataKey")
	local entryValueKey = ReadConf(config, "entryValueKey")
	local entryStaticKey = ReadConf(config, "entryStaticKey")
	local entryMethodKey = ReadConf(config, "entryMethodKey")

	assert(
		metadataKey and entryValueKey and entryStaticKey and entryMethodKey,
		"OOP compiler error\n  Invalid ObjectValuesOf<T> configuration."
	)

	local metadata = bundle:readproperty(metadataKey)
	assert(metadata and metadata:is("table"), "OOP compiler error\n  Class metadata not found.")

	local result = types.newtable()

	for name, property in metadata:properties() do
		local entry = property.read or property.write
		assert(
			entry and entry:is("table"),
			"OOP compiler error\n  Invalid metadata entry for '" .. tostring(name) .. "'."
		)

		local memberValue = entry:readproperty(entryValueKey)
		local staticValue = entry:readproperty(entryStaticKey)
		local methodValue = entry:readproperty(entryMethodKey)

		assert(memberValue, "OOP compiler error\n  Member '" .. tostring(name) .. "': metadata value not found.")
		assert(
			staticValue and staticValue:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata static state not found."
		)
		assert(
			methodValue and methodValue:is("singleton"),
			"OOP compiler error\n  Member '" .. tostring(name) .. "': metadata method state not found."
		)

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
		CompilerError("AssertObjectValuesOf<T, V> requires V to be a table.")
	end

	local required = ObjectValues(class, Config)

	if not value:issubtypeof(required) then
		CompilerError("Object value does not contain all required class fields.")
	end
	for key in value:properties() do
		if not required:readproperty(key) then
			CompilerError("Object value contains an unexpected field: " .. tostring(key) .. ".")
		end
	end

	return value
end

type function ParentViews(bundleValue: type, reference: type, base: type): type
	if base ~= nil and base ~= types.singleton(true) and base ~= types.singleton(false) then
		CompilerError("ParentsOf<T, R, B> expects a boolean literal for B.")
	end
	local bundle = FindBundle(bundleValue, Config)

	if bundle == types.never then
		CompilerError("ParentsOf<T, R> requires a class bundle.")
	end

	assert(bundle:is("table"), "OOP compiler error\n  Invalid class bundle for ParentsOf<T, R>.")

	local parentsKey = Config:readproperty(types.singleton("parentsKey"))
	local referenceKey = Config:readproperty(types.singleton("referenceKey"))

	assert(parentsKey and referenceKey, "OOP compiler error\n  Invalid ParentsOf<T, R> configuration.")

	local target = reference:readproperty(referenceKey) :: type

	if not target then
		CompilerError("ParentsOf<T, R> requires a valid class reference.")
	end

	local parents = bundle:readproperty(parentsKey)

	assert(parents and parents:is("function"), "OOP compiler error\n  Class parent pack not found.")

	local returns = parents:returns()

	if returns.tail then
		CompilerError("Class parent pack must be concrete.")
	end

	local arguments: { type } = {}

	for _, parent in returns.head or {} do
		local parentBundle = FindBundle(parent, Config)

		if parentBundle == types.never then
			CompilerError("Invalid class parent in ParentsOf<T, R>.")
		end

		assert(parentBundle:is("table"), "OOP compiler error\n  Invalid parent bundle in ParentsOf<T, R>.")

		local selected = if base == types.singleton(true) then BaseBundle(parent) else parentBundle
		local view = selected:readproperty(target) :: type

		if not view then
			CompilerError("Parent does not provide the requested reference view.")
		end

		table.insert(arguments, Pack(view, selected))
	end

	return types.newfunction({
		head = arguments,
	}, {
		head = {},
	})
end

-- References

type SelfReference = Reference<index<Config, "self">, Config>
type ObjectReference = Reference<index<Config, "object">, Config>
type ClassReference = Reference<index<Config, "class">, Config>
type ImplReference = Reference<index<Config, "impl">, Config>

export type Self = SelfReference
export type Object = ObjectReference
export type ClassType = ClassReference
export type Impl = ImplReference

-- Views

export type View<T, K> = ConvertDispatch<T, K, Config>
export type ViewOf<T, K> = Extract<T, K, Config>

--[[
	this returns a bundle with object view as primary, so user can use the type
	Type = Class<{}> to point to object of the class
]]
export type Class<T, A...> = Compile<T, index<Config, "classKind">, Config, () -> A...>
export type Refine<Base, Spec, Parents...> = RefineClass<Base, Spec, Config, () -> Parents...>

export type Interface<T> = Compile<T, index<Config, "interfaceKind">, Config, () -> ()>
export type Trait<T> = Compile<T, index<Config, "traitKind">, Config, () -> ()>
export type Override<T> = ApplyOverride<T, Config>

export type ToClass<T> = ConvertDispatch<T, index<Config, "class">, Config>
export type ToObject<T> = ConvertDispatch<T, index<Config, "object">, Config>
export type ToSelf<T> = ConvertDispatch<T, index<Config, "self">, Config>
export type ToImpl<T> = ConvertDispatch<T, index<Config, "impl">, Config>
export type ToSpec<T> = ConvertDispatch<T, index<Config, "spec">, Config>
export type ToBase<T> = BaseView<T, index<Config, "class">>
export type ParentsOf<T, R, B = false> = ParentViews<T, R, B>

-- Extractors

export type ClassOf<T> = Extract<T, index<Config, "class">, Config>
export type ObjectOf<T> = Extract<T, index<Config, "object">, Config>
export type SelfOf<T> = Extract<T, index<Config, "self">, Config>
export type ImplOf<T> = Extract<T, index<Config, "impl">, Config>
export type SpecOf<T> = Extract<T, index<Config, "spec">, Config>
export type BaseOf<T> = BaseView<T, index<Config, "class">>

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
