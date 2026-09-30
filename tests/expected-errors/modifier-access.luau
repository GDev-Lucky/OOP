--!strict

-- Test: Modifier visibility, assignment, method injection, and immutability
-- Result: expected type errors
-- Pass condition: each invalid check below is rejected; fixtures type-check.
-- Note: Indexer entries are permitted writes and are tested in positive/inventory-views.luau.

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
type Self = oop.Self
type Object = oop.Object
type ClassOf<T> = oop.ClassOf<T>
type ObjectOf<T> = oop.ObjectOf<T>
type SelfOf<T> = oop.SelfOf<T>
type ImplOf<T> = oop.ImplOf<T>

local function any(): any
	return nil :: any
end

type NumberFunction = (number) -> number

type GenericIdentity = <T>(T) -> T

type NestedMutable = {
	value: number,

	nested: {
		text: string,

		deeper: {
			flag: boolean,
		},
	},

	array: {
		{
			score: number,
		}
	},

	dictionary: {
		[string]: {
			count: number,
		},
	},
}

-- Check: Modifier Matrix
-- Pass condition: this rejected access or assignment produces a type diagnostic.

type ModifierMatrixSpec = {
	defaultValue: number,
	defaultMethod: (number) -> number,

	explicitPublic: Public<number>,
	explicitPrivate: Private<number>,

	publicMethod: Public<(number) -> number>,
	privateMethod: Private<(number) -> number>,

	publicWins: Public<Private<number>>,
	privateWins: Private<Public<number>>,

	defaultStatic: Static<number>,

	publicStaticA: Public<Static<number>>,
	publicStaticB: Static<Public<number>>,

	privateStaticA: Private<Static<number>>,
	privateStaticB: Static<Private<number>>,

	publicStaticFunction: Public<Static<NumberFunction>>,
	privateStaticFunction: Private<Static<NumberFunction>>,

	explicitMethod: Method<NumberFunction>,
	explicitField: Field<NumberFunction>,

	fieldWins: Field<Method<NumberFunction>>,
	methodWins: Method<Field<NumberFunction>>,

	staticForcesField: Static<Method<NumberFunction>>,
	methodOverridesStatic: Method<Static<NumberFunction>>,

	defaultConst: number,

	explicitConst: Const<number>,
	explicitVar: Var<number>,

	varWins: Var<Const<number>>,
	constWins: Const<Var<number>>,

	varMethod: Var<Method<NumberFunction>>,
	varField: Var<Field<NumberFunction>>,

	varStatic: Var<Static<number>>,
	constStatic: Const<Static<number>>,

	defaultMutable: NestedMutable,

	explicitMut: Mut<NestedMutable>,
	explicitImmut: Immut<NestedMutable>,

	mutWins: Mut<Immut<NestedMutable>>,
	immutWins: Immut<Mut<NestedMutable>>,

	constMutable: Const<Mut<NestedMutable>>,
	varImmutable: Var<Immut<NestedMutable>>,
}

type ModifierMatrix = Class<ModifierMatrixSpec>

type ModifierMatrixObject = ObjectOf<ModifierMatrix>
type ModifierMatrixSelf = SelfOf<ModifierMatrix>
type ModifierMatrixClass = ClassOf<ModifierMatrix>
type ModifierMatrixImpl = ImplOf<ModifierMatrix>

local matrixObject: ModifierMatrixObject = any()
local matrixSelf: ModifierMatrixSelf = any()
local matrixClass: ModifierMatrixClass = any()
local matrixImpl: ModifierMatrixImpl = any()

-- Check: Const
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixObject.defaultValue = 1
matrixObject.defaultConst = 1
matrixObject.explicitConst = 1

matrixObject.constWins = 1

-- Check: Private Visibility
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _privateObject = matrixObject.explicitPrivate

local _privateWinsObject = matrixObject.privateWins

-- Check: Static Not On Object
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _staticOnObject = matrixObject.defaultStatic

local _publicStaticOnObject = matrixObject.publicStaticA

-- Check: Static Not On Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _staticOnSelf = matrixSelf.defaultStatic

local _publicStaticOnSelf = matrixSelf.publicStaticA

-- Check: Private Static Not On Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _privateStaticA = matrixClass.privateStaticA

local _privateStaticB = matrixClass.privateStaticB

local _privateStaticFunction = matrixClass.privateStaticFunction

-- Check: Private Non Static Value Not On Impl
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _privateImplValue = matrixImpl.explicitPrivate

-- Check: Instance Value Not On Class
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _publicInstanceOnClass = matrixClass.explicitPublic

local _defaultValueOnClass = matrixClass.defaultValue

-- Check: Method Requires Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _missingMethodSelf = matrixObject.explicitMethod(1)

-- Check: Field Does Not Inject Self
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _fieldColon = matrixObject:explicitField(1)

local _fieldWinsColon = matrixObject:fieldWins(1)

-- Check: Method Wins
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _methodWinsMissingSelf = matrixObject.methodWins(1)

-- Check: Static Forces Field
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _staticForcedFieldColon = matrixClass:staticForcesField(1)

-- Check: Method Outside Static Re-Enables Injection
-- Pass condition: this rejected access or assignment produces a type diagnostic.

local _staticMethodMissingSelf = matrixClass.methodOverridesStatic(1)

-- Check: Const Static
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixClass.constStatic = 10

-- Check: Immutable Table
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixObject.explicitImmut.value = 1

matrixObject.explicitImmut.nested.text = "no"

matrixObject.explicitImmut.nested.deeper.flag = false

matrixObject.explicitImmut.array[1].score = 1

matrixObject.explicitImmut.dictionary.foo.count = 1

-- Check: Outer Immut Wins
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixObject.immutWins.value = 1

matrixObject.immutWins.nested.text = "no"

matrixObject.immutWins.array[1].score = 1

matrixObject.immutWins.dictionary.foo.count = 1

-- Check: Const Mutable Property
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixObject.constMutable = any()

-- Check: Var Does Not Affect Internal Immutability
-- Pass condition: this rejected access or assignment produces a type diagnostic.

matrixObject.varImmutable.value = 1

matrixObject.varImmutable.nested.text = "no"

matrixObject.varImmutable.array[1].score = 1

matrixObject.varImmutable.dictionary.foo.count = 1
